//
//  ContentView.swift
//  Cropping Image Example
//
//  Created by Adrien Surugue on 16/07/2022.
//

import SwiftUI

struct CroppingView: View{
    
    @State private var croppedImage = UIImage(named: "Image")
    @State private var originalImage = UIImage(named: "Image")
    
    //MARK: - General size
    
    @State private var imageSize : CGSize = CGSize(width: 0, height: 0)
    @State private var cropSize : CGSize = CGSize(width: 0, height: 0)
    
    @State private var rightWidthFrame : CGFloat = 0.0
    @State private var leftWidthFrame : CGFloat = 0.0
    @State private var upHeightFrame : CGFloat = 0.0
    @State private var downHeightFrame : CGFloat = 0.0
    
    
    //MARK: - Logic variables
    
    @State private var isTopArrow: Bool = false
    @State private var isLeftArrow: Bool = false
    @State private var isShowingCroppedImage = false
    
    //MARK: - Magnification variables
    
    @State private var yTopMagnification : CGFloat = 1.0
    @State private var yLastTopMagnification : CGFloat = 1.0
    
    @State private var xLeftMagnification : CGFloat = 1.0
    @State private var xLastLeftMagnification : CGFloat = 1.0
    
    @State private var xRightMagnification : CGFloat = 1.0
    @State private var xLastRightMagnification : CGFloat = 1.0
    
    @State private var yBottomMagnification: CGFloat = 1.0
    @State private var yLastBottomMagnification: CGFloat = 1.0
    
    // MARK: - Gesture offset variables
    
    @State private var xTopLeftOffset : CGFloat = 0.0
    @State private var yTopLeftOffset : CGFloat = 0.0
    
    @State private var xTopRightOffset : CGFloat = 0.0
    @State private var yTopRightOffset : CGFloat = 0.0
    
    @State private var xBottomLeftOffset : CGFloat = 0.0
    @State private var yBottomLeftOffset: CGFloat = 0.0
    
    @State private var xBottomRightOffset:CGFloat = 0.0
    @State private var yBottomRightOffset: CGFloat = 0.0
    
    
    //MARK: - Top Last offset variables
    
    @State private var xLastLeftOffset : CGFloat = 0.0
    @State private var xLastRightOffset : CGFloat = 0.0
    @State private var yLastBottomOffset: CGFloat = 0.0
    @State private var yLastTopOffset : CGFloat = 0.0
    
    // MARK: - Offset variables
    
    @State private var leftOffset : CGSize = CGSize(width: 0, height: 0)
    @State private var finalLeftOffset : CGSize = CGSize(width: 0, height: 0)
    
    @State private var rightOffset : CGSize = CGSize(width: 0, height: 0)
    @State private var finalRightOffset : CGSize = CGSize(width: 0, height: 0)
    
    @State private var bottomOffset : CGSize = CGSize(width: 0, height: 0)
    @State private var finalBottomOffset: CGSize = CGSize(width: 0, height: 0)
    
    //MARK: - Total offset variables
    @State private var xTotalRightOffset: CGFloat = 0.0
    @State private var xTotalLeftOffset : CGFloat = 0.0
    @State private var yTotalBottomOffset: CGFloat = 0.0
    @State private var yTotalTopOffset : CGFloat = 0.0
    
    var body: some View{
        
        NavigationView{
            ZStack{
                Color.black
                Image(uiImage: originalImage!)
                    .resizable()
                    .scaledToFit()
                    .frame(width: UIScreen.main.bounds.width)
                    .overlay(GeometryReader{geometry -> AnyView in
                        DispatchQueue.main.async{
                            //Get image size
                            imageSize = geometry.size
                            
                            //Get crop zone size
                            cropSize = geometry.size
                            
                            //Get height of top and bottom rectangles according to the height of the crop and height of th screen
                            upHeightFrame = (geometry.size.height-cropSize.height)/2
                            downHeightFrame = (geometry.size.height-cropSize.height)/2
                            leftWidthFrame = (geometry.size.width-cropSize.width)/2
                            rightWidthFrame = (geometry.size.width-cropSize.width)/2
                        }
                        return AnyView(EmptyView())
                        
                    })
                
                //MARK: - Mask rectangles
                Rectangle()
                    .foregroundColor(.black.opacity(0.8))
                    .frame(width: imageSize.width, height: upHeightFrame + yTotalTopOffset)
                    .offset(y:-(upHeightFrame+cropSize.height)/2 + leftOffset.height)
                
                Rectangle()
                    .foregroundColor(.black.opacity(0.8))
                    .frame(width: imageSize.width, height: upHeightFrame - yTotalBottomOffset)
                    .offset(y:(upHeightFrame+cropSize.height)/2 + bottomOffset.height)
                Rectangle()
                    .foregroundColor(.black.opacity(0.8))
                    .frame(width: rightWidthFrame - xTotalRightOffset, height: isTopArrow ? cropSize.height - (yTotalTopOffset-yTotalBottomOffset) : cropSize.height - (yTotalTopOffset - yTotalBottomOffset))
                    .offset(x:(leftWidthFrame+cropSize.width)/2 + rightOffset.width, y: isTopArrow ? leftOffset.height + finalBottomOffset.height : bottomOffset.height + finalLeftOffset.height)
                Rectangle()
                    .foregroundColor(.black.opacity(0.8))
                    .frame(width: leftWidthFrame+xTotalLeftOffset, height: isTopArrow ? cropSize.height - (yTotalTopOffset-yTotalBottomOffset) : cropSize.height-(yTotalTopOffset - yTotalBottomOffset))
                    .offset(x:-(leftWidthFrame+cropSize.width)/2 + leftOffset.width, y: isTopArrow ? leftOffset.height + finalBottomOffset.height : bottomOffset.height + finalLeftOffset.height)
                
                //MARK: - Parent rectangle
                Group{
                    Rectangle()
                        .stroke(lineWidth: 0.8)
                        .frame(width: isLeftArrow ? (cropSize.width)*((xLeftMagnification+xLastRightMagnification)-1) : (cropSize.width)*((xRightMagnification + xLastLeftMagnification)-1),
                               height: isTopArrow ? (cropSize.height/3) * ((yTopMagnification + yLastBottomMagnification)-1) : (cropSize.height/3) * ((yBottomMagnification + yLastTopMagnification)-1))
                        .foregroundColor(.white)
                        .offset(x: isLeftArrow ? leftOffset.width+finalRightOffset.width  : rightOffset.width+finalLeftOffset.width ,
                                y: isTopArrow ? leftOffset.height+finalBottomOffset.height : bottomOffset.height + finalLeftOffset.height)
                    Rectangle()
                        .stroke(lineWidth: 0.5)
                        .frame(width: isLeftArrow ? (cropSize.width/3)*((xLeftMagnification+xLastRightMagnification)-1) : (cropSize.width/3)*((xRightMagnification + xLastLeftMagnification)-1),
                               height: isTopArrow ? (cropSize.height) * ((yTopMagnification + yLastBottomMagnification)-1) : (cropSize.height) * ((yBottomMagnification + yLastTopMagnification)-1))
                        .foregroundColor(.white)
                        .offset(x: isLeftArrow ? leftOffset.width+finalRightOffset.width  : rightOffset.width+finalLeftOffset.width ,
                                y: isTopArrow ? leftOffset.height+finalBottomOffset.height : bottomOffset.height + finalLeftOffset.height)
                    Rectangle()
                        .stroke(lineWidth: 2)
                        .frame(width: isLeftArrow ? (cropSize.width)*((xLeftMagnification+xLastRightMagnification)-1) : (cropSize.width)*((xRightMagnification + xLastLeftMagnification)-1),
                               height: isTopArrow ? (cropSize.height) * ((yTopMagnification + yLastBottomMagnification)-1) : (cropSize.height) * ((yBottomMagnification + yLastTopMagnification)-1))
                        .foregroundColor(.white)
                        .offset(x: isLeftArrow ? leftOffset.width+finalRightOffset.width  : rightOffset.width+finalLeftOffset.width ,
                                y: isTopArrow ? leftOffset.height+finalBottomOffset.height : bottomOffset.height + finalLeftOffset.height)
                }
                Group{
                    
                    //MARK: - Top-Left side
                    
                    Image("arrow.top.left")
                        .resizable()
                        .font(.system(size: 12))
                        .frame(width: 50, height: 50)
                        .foregroundColor(.white)
                        .offset(x: (leftOffset.width) - (xLeftMagnification * cropSize.width)/2,
                                y: (leftOffset.height) - (yTopMagnification * cropSize.height)/2)
                        .gesture(DragGesture().onChanged({gesture in
                            
                            isLeftArrow = true
                            isTopArrow = true
                            
                            //Get offset gesture
                            xTopLeftOffset = gesture.translation.width + xLastLeftOffset
                            yTopLeftOffset = gesture.translation.height + yLastTopOffset
                            
                            //Get the ratio of crop magnification
                            xLeftMagnification = (cropSize.width-xTopLeftOffset)/cropSize.width
                            yTopMagnification = (cropSize.height-yTopLeftOffset)/cropSize.height
                            
                            //limit when halving cropping in x
                            if (xLeftMagnification + xLastRightMagnification) - 1 <= 0.5{
                                xLeftMagnification = (1 - xLastRightMagnification) + 0.5
                            }
                            
                            //Limit when halving cropping in y
                            if (yTopMagnification + yBottomMagnification) - 1 <= 0.5{
                                yTopMagnification = (1-yLastBottomMagnification) + 0.5
                            }
                            
                            //Limit on the left edges of the screen
                            if xTopLeftOffset <= -((imageSize.width-cropSize.width)/2){
                                xLeftMagnification = (leftWidthFrame/cropSize.width) + 1
                            }
                            
                            //Limit on the top edges of the screen
                            if yTopLeftOffset <= -((imageSize.height-cropSize.height)/2){
                                yTopMagnification = (upHeightFrame/cropSize.height) + 1
                            }
                            
                            //As you magnify, you technically need to modify offset as well, because magnification changes are not symmetric, meaning that you are modifying the magnfiication only be shifting the upper and left edges inwards, thus changing the center of the croppedingview, so the offset needs to move accordingly
                            let xOffsetSize = (cropSize.width * xLastLeftMagnification)-(cropSize.width * xLeftMagnification)
                            let yOffsetSize = (cropSize.height * yLastTopMagnification) - (cropSize.height * yTopMagnification)
                            
                            leftOffset.width = (finalLeftOffset.width) + (xOffsetSize)/2
                            leftOffset.height = (finalLeftOffset.height) + yOffsetSize/2
                            
                            xTotalLeftOffset = leftOffset.width*2
                            yTotalTopOffset = leftOffset.height*2
                            
                        }).onEnded({ _ in
                            
                            //Store the last gesture offset it's used for magnification calculations in x
                            if (xLeftMagnification+xLastRightMagnification)-1 <= 0.5{
                                //Set value limit when halving cropping in x
                                xLastLeftOffset = cropSize.width/2 + xLastRightOffset
                            } else {
                                xLastLeftOffset = xTopLeftOffset
                            }
                            
                            //Store the last gesture offset it's used for magnification calculations in y
                            if (yTopMagnification + yLastBottomMagnification) - 1 <= 0.5{
                                //Set value limit when halving cropping in y
                                yLastTopOffset = cropSize.height/2 + yLastBottomOffset
                            } else {
                                yLastTopOffset = yTopLeftOffset
                            }
                            //Store the last gesture offset when its on left limit
                            if xTopLeftOffset <= -((imageSize.width-cropSize.width)/2){
                                xLastLeftOffset = -((imageSize.width-cropSize.width)/2)
                            }
                            
                            //Store the last gesture offset when its on top limit
                            if yTopLeftOffset <= -((imageSize.height-cropSize.height)/2){
                                yLastTopOffset = -((imageSize.height-cropSize.height)/2)
                            }
                            
                            //Store last magnification ratio it's used for crop calculations
                            xLastLeftMagnification = xLeftMagnification
                            yLastTopMagnification = yTopMagnification
                            
                            //Store the last offset it's used for the continuation of cropping
                            finalLeftOffset = leftOffset
                            
                            
                            let imageViewScale = max(originalImage!.size.width / imageSize.width,
                                                     originalImage!.size.height / imageSize.height)
                            
                            let cropRect = CGRect(x: xLastLeftOffset, y: yLastTopOffset, width: (cropSize.width)*((xLeftMagnification+xLastRightMagnification)-1), height: (cropSize.height) * ((yTopMagnification + yLastBottomMagnification)-1))
                            
                            let cropZone = CGRect(x:cropRect.origin.x * imageViewScale,
                                                  y:cropRect.origin.y * imageViewScale,
                                                  width:cropRect.size.width * imageViewScale,
                                                  height:cropRect.size.height * imageViewScale)
                            
                            let cropImage: CGImage = (originalImage?.cgImage?.cropping(to:cropZone))!
                            
                            croppedImage = UIImage(cgImage: cropImage)
                            
                            isShowingCroppedImage.toggle()
        
                        }))
                    
                    NavigationLink(destination: CroppedImage(image: croppedImage!), isActive: $isShowingCroppedImage){
                        EmptyView()
                    }
                    
                    //MARK: - Top-Right side
                    
                    Image("arrow.top.right")
                        .resizable()
                        .font(.system(size: 12))
                        .frame(width: 50, height: 50)
                        .foregroundColor(.white)
                        .offset(x: (rightOffset.width) + (xRightMagnification * cropSize.width)/2,
                                y: (leftOffset.height) - (yTopMagnification * cropSize.height)/2)
                        .gesture(DragGesture().onChanged({gesture in
                            
                            isLeftArrow = false
                            isTopArrow = true
                            
                            //Get offset gesture
                            xTopRightOffset = gesture.translation.width + xLastRightOffset
                            yTopRightOffset = gesture.translation.height + yLastTopOffset
                            
                            //Get the ratio of crop magnification
                            xRightMagnification = (cropSize.width+xTopRightOffset)/cropSize.width
                            yTopMagnification = (cropSize.height-yTopRightOffset)/cropSize.height
                            
                            //limit when halving cropping on x
                            if (xRightMagnification+xLastLeftMagnification)-1 <= 0.5{
                                xRightMagnification = (1-xLastLeftMagnification)+0.5
                            }
                            
                            //limit when halving cropping on y
                            if (yTopMagnification + yBottomMagnification - 1) <= 0.5{
                                yTopMagnification = (1 - yLastBottomMagnification) + 0.5
                            }
                            
                            //Limit on the right edges of the screen
                            if xTopRightOffset >= ((imageSize.width-cropSize.width)/2){
                                xRightMagnification = (rightWidthFrame/cropSize.width) + 1
                            }
                            
                            //Limit on the top edges of the screen
                            if yTopRightOffset <= -((imageSize.height-cropSize.height)/2){
                                yTopMagnification = (upHeightFrame/cropSize.height) + 1
                                
                            }
                            
                            let xOffsetSize = (cropSize.width * xLastRightMagnification) - (cropSize.width * xRightMagnification)
                            let yOffsetSize = (cropSize.height * yLastTopMagnification) - (cropSize.height * yTopMagnification)
                            
                            rightOffset.width = (finalRightOffset.width) - xOffsetSize/2
                            leftOffset.height = finalLeftOffset.height + yOffsetSize/2
                            
                            xTotalRightOffset = rightOffset.width*2
                            yTotalTopOffset = leftOffset.height*2
                            
                        }).onEnded({_ in
                            
                            //Store the last gesture offset it's used for magnification calculations
                            if (xRightMagnification+xLastLeftMagnification)-1 <= 0.5{
                                //Set value limit when halving cropping in x
                                xLastRightOffset = -cropSize.width/2 + xLastLeftOffset
                            } else {
                                xLastRightOffset = xTopRightOffset
                            }
                            
                            //Store the last gesture offset it's used for magnification calculations in y
                            if (yTopMagnification + yLastBottomMagnification) - 1 <= 0.5 {
                                //Set value limit when halving cropping in y
                                yLastTopOffset = cropSize.width/2 + yLastBottomOffset
                            } else {
                                yLastTopOffset = yTopRightOffset
                            }
                            
                            //Store the last gesture offset when its on right limit
                            if xTopRightOffset >= ((imageSize.width-cropSize.width)/2){
                                xLastRightOffset = ((imageSize.width-cropSize.width)/2)
                            }
                            
                            //Store the last gesture offset when its on top limit
                            if yTopRightOffset <= -((imageSize.height-cropSize.height)/2){
                                yLastTopOffset = -((imageSize.height-cropSize.height)/2)
                            }
                            
                            //Store last magnification ratio it's used for crop calculations
                            xLastRightMagnification = xRightMagnification
                            yLastTopMagnification = yTopMagnification
                            
                            //Store the last offset it's used for the continuation of cropping
                            finalLeftOffset = leftOffset
                            finalRightOffset = rightOffset
                        }))
                    
                    //MARK: - Bottom-Left side
                    
                    Image("arrow.bottom.left")
                        .resizable()
                        .font(.system(size: 12))
                        .frame(width: 50, height: 50)
                        .foregroundColor(.white)
                        .offset(x: (leftOffset.width) - (xLeftMagnification * cropSize.width)/2,
                                y: (bottomOffset.height) + (yBottomMagnification * cropSize.height)/2)
                        .gesture(DragGesture().onChanged({gesture in
                            
                            isLeftArrow = true
                            isTopArrow = false
                            
                            //Get offset gesture
                            xBottomLeftOffset = gesture.translation.width + xLastLeftOffset
                            yBottomLeftOffset = gesture.translation.height + yLastBottomOffset
                            
                            //Get the ratio of crop magnification
                            xLeftMagnification = (cropSize.width-xBottomLeftOffset)/cropSize.width
                            yBottomMagnification = (cropSize.height+yBottomLeftOffset)/cropSize.height
                            
                            //limit when halving cropping in x
                            if (xLeftMagnification + xLastRightMagnification) - 1 <= 0.5{
                                xLeftMagnification = (1 - xLastRightMagnification) + 0.5
                            }
                            
                            //Limit when halving cropping in y
                            if (yBottomMagnification + yTopMagnification) - 1 <=  0.5{
                                yBottomMagnification =  (1-yLastTopMagnification) + 0.5
                            }
                            
                            //Limit on the left edges of the screen
                            if xBottomLeftOffset <= -((imageSize.width-cropSize.width)/2){
                                xLeftMagnification = (leftWidthFrame/cropSize.width) + 1
                            }
                            
                            
                            //Limit on the top edges of the screen
                            if yBottomLeftOffset >= ((imageSize.height-cropSize.height)/2){
                                yBottomMagnification = (downHeightFrame/cropSize.height) + 1
                            }
                            
                            //As you magnify, you technically need to modify offset as well, because magnification changes are not symmetric, meaning that you are modifying the magnfiication only be shifting the upper and left edges inwards, thus changing the center of the croppedingview, so the offset needs to move accordingly
                            let xOffsetSize = (cropSize.width * xLastLeftMagnification)-(cropSize.width * xLeftMagnification)
                            let yOffsetSize = (cropSize.height * yLastBottomMagnification) - (cropSize.height * yBottomMagnification)
                            
                            leftOffset.width = (finalLeftOffset.width) + (xOffsetSize)/2
                            bottomOffset.height = (finalBottomOffset.height) - yOffsetSize/2
                            
                            xTotalLeftOffset = leftOffset.width*2
                            yTotalBottomOffset = bottomOffset.height*2
                            
                            
                        }).onEnded({ _ in
                            
                            //Store the last gesture offset it's used for magnification calculations in x
                            if (xLeftMagnification+xLastRightMagnification)-1 <= 0.5{
                                //Set value limit when halving cropping in x
                                xLastLeftOffset = cropSize.width/2 + xLastRightOffset
                            } else {
                                xLastLeftOffset = xBottomLeftOffset
                            }
                            
                            //Store the last gesture offset it's used for magnification calculations in y
                            if (yBottomMagnification + yLastTopMagnification)-1 <= 0.5{
                                //Set value limit when halving cropping in y
                                yLastBottomOffset = -cropSize.height/2 + yLastTopOffset
                            } else {
                                yLastBottomOffset = yBottomLeftOffset
                            }
                            
                            //Store the last gesture offset when its on left limit
                            if xBottomLeftOffset <= -((imageSize.width-cropSize.width)/2){
                                xLastLeftOffset = -((imageSize.width-cropSize.width)/2)
                            }
                            
                            //Store the last gesture offset when its on bottom limit
                            if yBottomLeftOffset >= ((imageSize.height-cropSize.height)/2){
                                yLastBottomOffset = ((imageSize.height-cropSize.height)/2)
                            }
                            
                            //Store last magnification ratio it's used for crop calculations
                            xLastLeftMagnification = xLeftMagnification
                            yLastBottomMagnification = yBottomMagnification
                            
                            //Store the last offset it's used for the continuation of cropping
                            finalLeftOffset = leftOffset
                            finalBottomOffset = bottomOffset
                        }))
                    
                    //MARK: - Bottom-Right Side
                    
                    Image("arrow.bottom.right")
                        .resizable()
                        .font(.system(size: 12))
                        .frame(width: 50, height: 50)
                        .foregroundColor(.white)
                        .offset(x: (rightOffset.width) + (xRightMagnification * cropSize.width)/2,
                                y: (bottomOffset.height) + (yBottomMagnification * cropSize.height)/2)
                    
                        .gesture(DragGesture().onChanged({ gesture in
                            
                            isLeftArrow = false
                            isTopArrow = false
                            
                            xBottomRightOffset = gesture.translation.width + xLastRightOffset
                            yBottomRightOffset = gesture.translation.height + yLastBottomOffset
                            
                            //Get the ratio of crop magnification
                            xRightMagnification = (cropSize.width+xBottomRightOffset)/cropSize.width
                            yBottomMagnification = (cropSize.height+yBottomRightOffset)/cropSize.height
                            
                            //limit when halving cropping on x
                            if (xRightMagnification+xLastLeftMagnification)-1 <= 0.5{
                                xRightMagnification = (1-xLastLeftMagnification)+0.5
                            }
                            
                            //Limit when halving cropping in y
                            if (yBottomMagnification + yTopMagnification) - 1 <=  0.5{
                                yBottomMagnification =  (1 - yLastTopMagnification) + 0.5
                            }
                            
                            //Limit on the left edges of the screen
                            if xBottomRightOffset >= ((imageSize.width-cropSize.width)/2){
                                xRightMagnification = (rightWidthFrame/cropSize.width) + 1
                            }
                            
                            //Limit on the bottom edges of the screen
                            if yBottomRightOffset >= ((imageSize.height-cropSize.height)/2){
                                yBottomMagnification = (downHeightFrame/cropSize.height) + 1
                            }
                            
                            //As you magnify, you technically need to modify offset as well, because magnification changes are not symmetric, meaning that you are modifying the magnfiication only be shifting the upper and left edges inwards, thus changing the center of the croppedingview, so the offset needs to move accordingly
                            let xOffsetSize = (cropSize.width * xLastRightMagnification) - (cropSize.width * xRightMagnification)
                            let yOffsetSize = (cropSize.height * yLastBottomMagnification) - (cropSize.height * yBottomMagnification)
                            
                            rightOffset.width = (finalRightOffset.width) - (xOffsetSize)/2
                            bottomOffset.height = (finalBottomOffset.height) - yOffsetSize/2
                            
                            xTotalRightOffset = rightOffset.width*2
                            yTotalBottomOffset = bottomOffset.height*2
                            
                        }).onEnded({ _ in
                            //Store the last gesture offset it's used for magnification calculations
                            if (xRightMagnification+xLastLeftMagnification)-1 <= 0.5{
                                //Set value limit when halving cropping in x
                                xLastRightOffset = -cropSize.width/2 + xLastLeftOffset
                            } else {
                                xLastRightOffset = xBottomRightOffset
                            }
                            
                            //Store the last gesture offset it's used for magnification calculations in y
                            if (yBottomMagnification + yLastTopMagnification)-1 <= 0.5{
                                //Set value limit when halving cropping in y
                                yLastBottomOffset = -cropSize.height/2 + yLastTopOffset
                            } else {
                                yLastBottomOffset = yBottomRightOffset
                            }
                            
                            //Store the last gesture offset when its on right limit
                            if xBottomRightOffset >= ((imageSize.width-cropSize.width)/2){
                                xLastRightOffset = ((imageSize.width-cropSize.width)/2)
                            }
                            
                            //Store the last gesture offset when its on bottom limit
                            if yBottomRightOffset >= ((imageSize.height-cropSize.height)/2){
                                yLastBottomOffset = ((imageSize.height-cropSize.height)/2)
                            }
                            
                            //Store last magnification ratio it's used for crop calculations
                            xLastRightMagnification = xRightMagnification
                            yLastBottomMagnification = yBottomMagnification
                            
                            //Store the last offset it's used for the continuation of cropping
                            finalRightOffset = rightOffset
                            finalBottomOffset = bottomOffset
                        }))
                }
            }
            .ignoresSafeArea()
        }
        .navigationViewStyle(.stack)
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        CroppingView()
    }
}
