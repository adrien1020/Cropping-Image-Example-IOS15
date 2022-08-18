//
//  CroppingViewModel.swift
//  Cropping Image Example
//
//  Created by Adrien Surugue on 08/08/2022.
//

import Foundation
import SwiftUI


extension CroppingView{
    @MainActor
    class CroppingViewModel: ObservableObject {

        var side: Side = .topLeft
        
        func getMagnification(xOffset: CGFloat, yOffset: CGFloat, cropSize: CGSize)->CGSize{
            
                let xMagnification = (cropSize.width + xOffset) / cropSize.width
                let yMagnification = (cropSize.height + yOffset) / cropSize.height
                return CGSize(width: xMagnification, height: yMagnification)
            }
        
        func addReducingLimit(magnification: CGSize, xLastOpposedMagnification: CGFloat, yLastOpposedMagnification: CGFloat)->CGSize{
            
            var magni = CGSize(width: magnification.width, height: magnification.height)
            
            //Limit when reducing cropping in x
            if (magnification.width + xLastOpposedMagnification) - 1 <= 0.5{
                magni.width = (1 - xLastOpposedMagnification) + 0.5
            }
            
            //Limit when reducing cropping in y
            if (magnification.height + yLastOpposedMagnification) - 1 <= 0.5{
                magni.height =  (1 - yLastOpposedMagnification) + 0.5
            }
            return magni
        }
        
        
        func addEdgesLimit(xOffset: CGFloat, yOffset: CGFloat, magnification: CGSize, imageSize: CGSize, cropSize: CGSize)-> CGSize {

          var magni = CGSize(width: magnification.width, height: magnification.height)
        
            //limit when on the edge in x
            if side.comparison.0(xOffset, (imageSize.width - cropSize.width) / 2) {
            magni.width = 1
          }
            
            //limit when on the edge in y
            if side.comparison.1(yOffset, (imageSize.height - cropSize.height) / 2) {
            magni.height = 1
          }
          return magni
        }
        
        func changeOffsetSize(magnification: CGSize, lastMagnification: CGSize, finalOffset: CGSize, cropSize: CGSize)->CGSize{
            //As you magnify, you technically need to modify offset as well, because magnification changes are not symmetric, meaning that you are modifying the magnification only be shifting the upper and left edges inwards, thus changing the center of the croppedingview, so the offset needs to move accordingly
            var offset = CGSize(width: 0, height: 0)
           
            let xOffsetSize = (cropSize.width * lastMagnification.width) - (cropSize.width * magnification.width)
            let yOffsetSize = (cropSize.height * lastMagnification.height) - (cropSize.height * magnification.height)
            
            offset.width = side.operation.0(finalOffset.width, xOffsetSize/2)
            offset.height = side.operation.1(finalOffset.height, yOffsetSize/2)
        
            return offset
        }
        
        func storeLastGesture(xOffset: CGFloat, yOffset: CGFloat, magnification: CGSize, xLastOpposedMagnification: CGFloat, yLastOpposedMagnification: CGFloat, xLastOpposedOffset:CGFloat, yLastOpposedOffset: CGFloat, cropSize: CGSize)->CGSize{
            
            var lastOffset = CGSize(width: xOffset, height: yOffset)
            
            //Store the last gesture offset it's used for magnification calculations in x
            if magnification.width + xLastOpposedMagnification - 1 <= 0.5{
                //Set value limit when halving cropping in x
                lastOffset.width = side.operation.0(xLastOpposedOffset, (cropSize.width/2))
            } else {
                lastOffset.width = xOffset
            }
            //Store the last gesture offset it's used for magnification calculations in y
            if magnification.height + yLastOpposedMagnification - 1 <= 0.5{
                //Set value limit when halving cropping in y
                lastOffset.height = side.operation.1(yLastOpposedOffset, (cropSize.height/2))
            } else {
                lastOffset.height = yOffset
            }
            return lastOffset
        }
        
        func storeLastLimitEdges(xOffset: CGFloat, yOffset:CGFloat, lastOffset: CGSize, imageSize: CGSize, cropSize: CGSize)->CGSize{
            var lastOffset = CGSize(width: lastOffset.width, height: lastOffset.height)
            
            //Store the last gesture offset when its on horizontal limit
            if side.comparison.0(xOffset, (imageSize.width - cropSize.width) / 2) {
                lastOffset.width = (imageSize.width - cropSize.width) / 2
            }
            
            //Store the last gesture offset when its on vertical limit
            if side.comparison.1(yOffset, (imageSize.height - cropSize.height) / 2) {
                lastOffset.height = (imageSize.height - cropSize.height) / 2
            }
            return lastOffset
            
        }
        
        func cropImage(originalImage: UIImage, lastOffset: CGSize, lastMagnification: CGSize, xLastOppositeMagnification: CGFloat, yLastOppositeMagnification: CGFloat, imageSize: CGSize, cropSize: CGSize) -> UIImage? {
            
            //Set the max scale
            let imageViewScale = max(originalImage.size.width / imageSize.width,
                                     originalImage.size.height / imageSize.height)
            
            //Define the cropping rectangle
            let cropRect = CGRect(x: lastOffset.width,
                                  y: lastOffset.height,
                                  width: (cropSize.width) * ((lastMagnification.width + xLastOppositeMagnification) - 1),
                                  height: (cropSize.height) * ((lastMagnification.height + yLastOppositeMagnification) - 1))
           
            // Scale cropRect to handle images larger than shown-on-screen size
            let cropZone = CGRect(x:cropRect.origin.x * imageViewScale,
                                  y:cropRect.origin.y * imageViewScale,
                                  width:cropRect.size.width * imageViewScale,
                                  height:cropRect.size.height * imageViewScale)
            
            
            let croppedImage = originalImage.croppedInRect(rect: cropZone)
            
            return croppedImage
        }
    
    }
}

extension UIImage {
    func croppedInRect(rect: CGRect) -> UIImage {
        func rad(_ degree: Double) -> CGFloat {
            return CGFloat((degree * .pi)/180)
        }

        var rectTransform: CGAffineTransform
        switch imageOrientation {
        case .left:
            rectTransform = CGAffineTransform(rotationAngle: rad(90)).translatedBy(x: 0, y: -self.size.height)
        case .right:
            rectTransform = CGAffineTransform(rotationAngle: rad(-90)).translatedBy(x: -self.size.width, y: 0)
        case .down:
            rectTransform = CGAffineTransform(rotationAngle: rad(-180)).translatedBy(x: -self.size.width, y: -self.size.height)
        default:
            rectTransform = .identity
        }
        rectTransform = rectTransform.scaledBy(x: self.scale, y: self.scale)
        let imageRef = self.cgImage!.cropping(to: rect.applying(rectTransform))
        
        // Perform cropping in Core Graphics
        return UIImage(cgImage: imageRef!, scale: self.scale, orientation: self.imageOrientation)
    }
}


