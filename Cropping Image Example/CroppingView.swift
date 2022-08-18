//
//  CroppingView.swift
//  Cropping Image Example
//
//  Created by Adrien Surugue on 08/08/2022.
//

import SwiftUI

struct CroppingView: View {
    
    @StateObject private var croppingVM = CroppingViewModel()
    @Namespace var namespace
    @Binding var originalImage: UIImage?
    @State private var croppedImage: UIImage?
    
    @State private var cropSize : CGSize = CGSize(width: 0, height: 0)
    @State private var imageSize : CGSize = CGSize(width: 0, height: 0)
    
    //MARK: - Logic variables
    
    @State private var isShowingCroppedImage: Bool = false
    @State private var isPerformingAnimation = false
    @Binding var isEditing: Bool
    
    //MARK: - Magnification variables
    
    @State private var topLeftMagnification: CGSize = CGSize(width: 1.0, height: 1.0)
    @State private var lastTopLeftMagnification: CGSize = CGSize(width: 1.0, height: 1.0)
    
    @State private var topRightMagnification: CGSize = CGSize(width: 1.0, height: 1.0)
    @State private var lastTopRightMagnification: CGSize = CGSize(width: 1.0, height: 1.0)
    
    @State private var bottomLeftMagnification: CGSize = CGSize(width: 1.0, height: 1.0)
    @State private var lastBottomLeftMagnification: CGSize = CGSize(width: 1.0, height: 1.0)
    
    @State private var bottomRightMagnification: CGSize = CGSize(width: 1.0, height: 1.0)
    @State private var lastBottomRightMagnification: CGSize = CGSize(width: 1.0, height: 1.0)
    
    // MARK: - Gesture offset variables
    
    @State private var xTopLeftOffset: CGFloat = 0.0
    @State private var yTopLeftOffset: CGFloat = 0.0
    
    @State private var xTopRightOffset: CGFloat = 0.0
    @State private var yTopRightOffset: CGFloat = 0.0
    
    @State private var xBottomLeftOffset: CGFloat = 0.0
    @State private var yBottomLeftOffset: CGFloat = 0.0
    
    @State private var xBottomRightOffset: CGFloat = 0.0
    @State private var yBottomRightOffset: CGFloat = 0.0
    
    // MARK: - Offset variables
    
    @State private var topLeftOffset : CGSize = CGSize(width: 0, height: 0)
    @State private var lastTopLeftOffset = CGSize(width: 0, height: 0)
    @State private var finalTopLeftOffset : CGSize = CGSize(width: 0, height: 0)
    
    @State private var topRightOffset : CGSize = CGSize(width: 0, height: 0)
    @State private var lastTopRightOffset = CGSize(width: 0, height: 0)
    @State private var finalTopRightOffset : CGSize = CGSize(width: 0, height: 0)
    
    @State private var bottomLeftOffset : CGSize = CGSize(width: 0, height: 0)
    @State private var lastBottomLeftOffset = CGSize(width: 0, height: 0)
    @State private var finalBottomLeftOffset: CGSize = CGSize(width: 0, height: 0)
    
    @State private var bottomRightOffset : CGSize = CGSize(width: 0, height: 0)
    @State private var lastBottomRightOffset = CGSize(width: 0, height: 0)
    @State private var finalBottomRightOffset: CGSize = CGSize(width: 0, height: 0)
    
    @State private var topLeftSideIsActive = false
    @State private var topRightSideIsActive = false
    @State private var bottomRightSideIsActive = false
    @State private var bottomLeftSideIsActive = false
    
    
    var body: some View{
        ZStack{
            Color.black
            if isShowingCroppedImage{
                Image(uiImage: originalImage!)
                    .resizable()
                    .scaledToFit()
                    .matchedGeometryEffect(id: "crop", in: namespace)
                    .overlay(GeometryReader{geometry -> AnyView in
                        DispatchQueue.main.async{
                            //Get image size
                            imageSize = geometry.size
                            //Get crop zone size
                            cropSize = geometry.size
                        }
                        return AnyView(EmptyView())
                    })
                    .frame(width: isEditing ? UIScreen.main.bounds.width - 100 : UIScreen.main.bounds.width)
                
            } else {
                Image(uiImage: (originalImage ??  UIImage(named: "Image"))!)
                    .resizable()
                    .scaledToFit()
                    .matchedGeometryEffect(id: "crop", in: namespace)
                    .overlay(GeometryReader{geometry -> AnyView in
                        DispatchQueue.main.async{
                            //Get image size
                            imageSize = geometry.size
                            
                            //Get crop zone size
                            cropSize = geometry.size
                        }
                        return AnyView(EmptyView())
                    })
                    .frame(width: isEditing ? UIScreen.main.bounds.width - 100 : UIScreen.main.bounds.width)
            }
            if isEditing{
                //MARK: - Mask rectangles
                
                //Top mask rectangle
                Group{
                    Rectangle()
                        .foregroundColor(isPerformingAnimation ? .black : .black.opacity(0.8))
                        .frame(width: imageSize.width,
                               height: topLeftOffset.height * 2)
                        .offset(y: -cropSize.height/2 + topLeftOffset.height)
                    
                    //Bottom mask rectangle
                    Rectangle()
                        .foregroundColor(isPerformingAnimation ? .black : .black.opacity(0.8))
                        .frame(width: imageSize.width,
                               height: -bottomLeftOffset.height * 2)
                        .offset(y: cropSize.height/2 + bottomLeftOffset.height)
                    
                    //Right mask rectangle
                    Rectangle()
                        .foregroundColor(isPerformingAnimation ? .black : .black.opacity(0.8))
                        .frame(width: -topRightOffset.width * 2,
                               height: cropSize.height - ((topLeftOffset.height*2) - (bottomLeftOffset.height*2)))
                        .offset(x:(cropSize.width)/2 + topRightOffset.width,
                                y: getCroppRectOffset().height)
                    
                    //Left mask rectangle
                    Rectangle()
                        .foregroundColor(isPerformingAnimation ? .black : .black.opacity(0.8))
                        .frame(width: topLeftOffset.width * 2,
                               height: cropSize.height - ((topLeftOffset.height*2) - (bottomLeftOffset.height*2)))
                        .offset(x: -(cropSize.width)/2 + topLeftOffset.width,
                                y: getCroppRectOffset().height)
                }
                
                //MARK: - Crop rectangle
                
                Group{
                    Rectangle()
                        .stroke(lineWidth: 0.8)
                        .frame(width: getCroppRectFrame(cropSize: cropSize.width).width,
                               height: getCroppRectFrame(cropSize: cropSize.height/3).height)
                        .foregroundColor(.white)
                        .offset(x: getCroppRectOffset().width, y: getCroppRectOffset().height)
                    Rectangle()
                        .stroke(lineWidth: 0.5)
                        .frame(width: getCroppRectFrame(cropSize: cropSize.width/3).width,
                               height: getCroppRectFrame(cropSize: cropSize.height).height)
                        .foregroundColor(.white)
                        .offset(x: getCroppRectOffset().width, y: getCroppRectOffset().height)
                    Rectangle()
                        .stroke(lineWidth: 2)
                        .frame(width: getCroppRectFrame(cropSize: cropSize.width).width,
                               height: getCroppRectFrame(cropSize: cropSize.height).height)
                        .foregroundColor(.white)
                        .offset(x: getCroppRectOffset().width, y: getCroppRectOffset().height)
                }
                
                Group{
                    
                    //MARK: - Top-left arrow
                    
                    Image("arrow.top.left")
                        .resizable()
                        .font(.system(size: 12))
                        .frame(width: 50, height: 50)
                        .foregroundColor(.white)
                        .offset(x: (topLeftOffset.width) - (topLeftMagnification.width * cropSize.width)/2,
                                y: (topLeftOffset.height) - (topLeftMagnification.height * cropSize.height)/2)
                        .gesture(DragGesture().onChanged({gesture in
                            bottomRightSideIsActive = false
                            topRightSideIsActive = false
                            topLeftSideIsActive = true
                            bottomLeftSideIsActive = false
                            croppingVM.side = .topLeft
                            
                            //Get offset drag gesture
                            xTopLeftOffset = gesture.translation.width + lastTopLeftOffset.width
                            yTopLeftOffset = gesture.translation.height + lastTopLeftOffset.height
                            
                            //Get the ratio of crop magnification
                            topLeftMagnification = croppingVM.getMagnification(xOffset: -xTopLeftOffset, yOffset: -yTopLeftOffset, cropSize: cropSize)
                            
                            //Add Limit when reducing
                            topLeftMagnification = croppingVM.addReducingLimit(magnification: topLeftMagnification,
                                                                               xLastOpposedMagnification: lastTopRightMagnification.width,
                                                                               yLastOpposedMagnification: lastBottomLeftMagnification.height)
                            
                            //Add edges limit
                            topLeftMagnification = croppingVM.addEdgesLimit(xOffset: xTopLeftOffset,
                                                                            yOffset: yTopLeftOffset,
                                                                            magnification: topLeftMagnification, imageSize: imageSize, cropSize: cropSize)
                            
                            //Get offset
                            topLeftOffset = croppingVM.changeOffsetSize(magnification: topLeftMagnification,
                                                                        lastMagnification: lastTopLeftMagnification,
                                                                        finalOffset: finalTopLeftOffset, cropSize: cropSize)
                            
                            //Set magnification and offset that are common in x
                            bottomLeftMagnification.width = topLeftMagnification.width
                            bottomLeftOffset.width = topLeftOffset.width
                            
                            //Set magnification and offset that are common in y
                            topRightMagnification.height = topLeftMagnification.height
                            topRightOffset.height = topLeftOffset.height
                            
                        }).onEnded({ _ in
                            bottomRightSideIsActive = false
                            topRightSideIsActive = false
                            topLeftSideIsActive = false
                            bottomLeftSideIsActive = false
                            
                            //Store last offset and last limit reducing gesture
                            lastTopLeftOffset = croppingVM.storeLastGesture(xOffset: xTopLeftOffset,
                                                                            yOffset: yTopLeftOffset,
                                                                            magnification: topLeftMagnification,
                                                                            xLastOpposedMagnification: lastTopRightMagnification.width,
                                                                            yLastOpposedMagnification: lastBottomLeftMagnification.height,
                                                                            xLastOpposedOffset: lastTopRightOffset.width ,
                                                                            yLastOpposedOffset: lastBottomLeftOffset.height, cropSize: cropSize)
                            
                            //Store last offset if offset is in limit edges
                            lastTopLeftOffset = croppingVM.storeLastLimitEdges(xOffset: xTopLeftOffset, yOffset: yTopLeftOffset, lastOffset: lastTopLeftOffset, imageSize: imageSize, cropSize: cropSize)
                            
                            
                            //Store last magnification and finial offset, it's used for crop calculations
                            lastTopLeftMagnification = topLeftMagnification
                            finalTopLeftOffset = topLeftOffset
                            
                            //Store magnification and offset that are common in x
                            lastBottomLeftMagnification.width = lastTopLeftMagnification.width
                            lastBottomLeftOffset.width = lastTopLeftOffset.width
                            finalBottomLeftOffset.width = topLeftOffset.width
                            
                            //Store magnification and offset that are common in y
                            lastTopRightMagnification.height = lastTopLeftMagnification.height
                            lastTopRightOffset.height = lastTopLeftOffset.height
                            finalTopRightOffset.height = topLeftOffset.height
                            
                            cropImage()
            
                        }))
                        .disabled(topRightSideIsActive || bottomLeftSideIsActive || bottomRightSideIsActive || isPerformingAnimation)
                    
                    //MARK: - Top-right arrow
                    
                    Image("arrow.top.right")
                        .resizable()
                        .font(.system(size: 12))
                        .frame(width: 50, height: 50)
                        .foregroundColor(.white)
                        .offset(x: (topRightOffset.width) + (topRightMagnification.width * cropSize.width) / 2,
                                y: (topRightOffset.height) - (topRightMagnification.height * cropSize.height) / 2)
                        .gesture(DragGesture().onChanged({gesture in
                            bottomRightSideIsActive = false
                            topRightSideIsActive = true
                            topLeftSideIsActive = false
                            bottomLeftSideIsActive = false
                            croppingVM.side = .topRight
                            
                            //Get offset drag gesture
                            xTopRightOffset = gesture.translation.width + lastTopRightOffset.width
                            yTopRightOffset = gesture.translation.height + lastTopRightOffset.height
                            
                            //Get the ratio of crop magnification
                            topRightMagnification = croppingVM.getMagnification(xOffset: xTopRightOffset, yOffset: -yTopRightOffset, cropSize: cropSize)
                            
                            print(topRightMagnification)
                            //Add Limit when reducing
                            topRightMagnification = croppingVM.addReducingLimit(magnification: topRightMagnification, xLastOpposedMagnification: lastTopLeftMagnification.width, yLastOpposedMagnification: lastBottomRightMagnification.height)
                            
                            //Add edges limit
                            topRightMagnification = croppingVM.addEdgesLimit(xOffset: xTopRightOffset, yOffset: yTopRightOffset, magnification: topRightMagnification, imageSize: imageSize, cropSize: cropSize)
                            
                            //get offset
                            topRightOffset = croppingVM.changeOffsetSize(magnification: topRightMagnification, lastMagnification: lastTopRightMagnification, finalOffset: finalTopRightOffset, cropSize: cropSize)
                            
                            //Set magnification and offset that are common in x
                            bottomRightMagnification.width = topRightMagnification.width
                            bottomRightOffset.width = topRightOffset.width
                            
                            //Set magnification and offset that are common in y
                            topLeftMagnification.height = topRightMagnification.height
                            topLeftOffset.height = topRightOffset.height
                            
                        }).onEnded({_ in
                            bottomRightSideIsActive = false
                            topRightSideIsActive = false
                            topLeftSideIsActive = false
                            bottomLeftSideIsActive = false
                            //Store last offset and last limit reducing gesture
                            lastTopRightOffset = croppingVM.storeLastGesture(xOffset: xTopRightOffset,
                                                                             yOffset: yTopRightOffset,
                                                                             magnification: topRightMagnification,
                                                                             xLastOpposedMagnification: lastTopLeftMagnification.width,
                                                                             yLastOpposedMagnification: lastBottomRightMagnification.height,
                                                                             xLastOpposedOffset: lastTopLeftOffset.width,
                                                                             yLastOpposedOffset:lastBottomRightOffset.height, cropSize: cropSize)
                            
                            //Store last offset if offset is in limit edges
                            lastTopRightOffset = croppingVM.storeLastLimitEdges(xOffset: xTopRightOffset,
                                                                                yOffset: yTopRightOffset,
                                                                                lastOffset: lastTopRightOffset, imageSize: imageSize, cropSize: cropSize)
                            
                            //Store last magnification and finial offset, it's used for crop calculations
                            lastTopRightMagnification = topRightMagnification
                            finalTopRightOffset = topRightOffset
                            
                            //Store magnification and offset that are common in x
                            lastBottomRightMagnification.width = lastTopRightMagnification.width
                            lastBottomRightOffset.width = lastTopRightOffset.width
                            finalBottomRightOffset.width = topRightOffset.width
                            
                            //Store magnification and offset that are common in y
                            lastTopLeftMagnification.height = lastTopRightMagnification.height
                            lastTopLeftOffset.height = lastTopRightOffset.height
                            finalTopLeftOffset.height = topRightOffset.height
                            
                            cropImage()
                            
                        }))
                    
                        .disabled(topLeftSideIsActive || bottomLeftSideIsActive || bottomRightSideIsActive || isPerformingAnimation)
                    //MARK: - Bottom-left arrow
                    
                    Image("arrow.bottom.left")
                        .resizable()
                        .font(.system(size: 12))
                        .frame(width: 50, height: 50)
                        .foregroundColor(.white)
                        .offset(x: (bottomLeftOffset.width) - (bottomLeftMagnification.width * cropSize.width) / 2 ,
                                y: (bottomLeftOffset.height) + (bottomLeftMagnification.height * cropSize.height) / 2)
                        .gesture(DragGesture().onChanged({gesture in
                            bottomRightSideIsActive = false
                            topRightSideIsActive = false
                            topLeftSideIsActive = false
                            bottomLeftSideIsActive = true
                            croppingVM.side = .bottomLeft
                            
                            //Get offset drag gesture
                            xBottomLeftOffset = gesture.translation.width + lastBottomLeftOffset.width
                            yBottomLeftOffset = gesture.translation.height + lastBottomLeftOffset.height
                            
                            //Get the ratio of crop magnification
                            bottomLeftMagnification = croppingVM.getMagnification(xOffset: -xBottomLeftOffset,
                                                                                  yOffset: yBottomLeftOffset, cropSize: cropSize)
                            
                            //Add limit when reducing
                            bottomLeftMagnification = croppingVM.addReducingLimit(magnification: bottomLeftMagnification,
                                                                                  xLastOpposedMagnification: lastBottomRightMagnification.width,
                                                                                  yLastOpposedMagnification: lastTopLeftMagnification.height)
                            
                            //Add edges limit
                            bottomLeftMagnification = croppingVM.addEdgesLimit(xOffset: xBottomLeftOffset,
                                                                               yOffset: yBottomLeftOffset,
                                                                               magnification: bottomLeftMagnification, imageSize: imageSize, cropSize: cropSize)
                            //Get offset
                            bottomLeftOffset = croppingVM.changeOffsetSize(
                                magnification: bottomLeftMagnification,
                                lastMagnification: lastBottomLeftMagnification,
                                finalOffset: finalBottomLeftOffset, cropSize: cropSize)
                            
                            //Set magnification and offset that are common in x
                            topLeftMagnification.width = bottomLeftMagnification.width
                            topLeftOffset.width = bottomLeftOffset.width
                            
                            //Set magnification and offset that are common in y
                            bottomRightMagnification.height = bottomLeftMagnification.height
                            bottomRightOffset.height = bottomLeftOffset.height
                            
                            
                        }).onEnded({ _ in
                            bottomRightSideIsActive = false
                            topRightSideIsActive = false
                            topLeftSideIsActive = false
                            bottomLeftSideIsActive = false
                            //Store last offset and last limit reducing gesture
                            lastBottomLeftOffset = croppingVM.storeLastGesture(xOffset: xBottomLeftOffset,
                                                                               yOffset: yBottomLeftOffset,
                                                                               magnification: bottomLeftMagnification,
                                                                               xLastOpposedMagnification: lastBottomRightMagnification.width,
                                                                               yLastOpposedMagnification: lastTopLeftMagnification.height,
                                                                               xLastOpposedOffset: lastBottomRightOffset.width,
                                                                               yLastOpposedOffset: lastTopLeftOffset.height, cropSize: cropSize)
                            
                            //Store last offset if offset is in limit edges
                            lastBottomLeftOffset = croppingVM.storeLastLimitEdges(xOffset: xBottomLeftOffset,
                                                                                  yOffset: yBottomLeftOffset,
                                                                                  lastOffset: lastBottomLeftOffset, imageSize: imageSize, cropSize: cropSize)
                            
                            //Store last magnification and finial offset, it's used for crop calculations
                            lastBottomLeftMagnification = bottomLeftMagnification
                            finalBottomLeftOffset = bottomLeftOffset
                            
                            //Store magnification and offset that are common in x
                            lastTopLeftMagnification.width = lastBottomLeftMagnification.width
                            lastTopLeftOffset.width = lastBottomLeftOffset.width
                            finalTopLeftOffset.width = bottomLeftOffset.width
                            
                            //Store magnification and offset that are common in y
                            lastBottomRightMagnification.height = lastBottomLeftMagnification.height
                            lastBottomRightOffset.height = lastBottomLeftOffset.height
                            finalBottomRightOffset.height = bottomLeftOffset.height
                            
                            cropImage()
                            
                        }))
                        .disabled(topLeftSideIsActive || topRightSideIsActive || bottomRightSideIsActive || isPerformingAnimation)
                    
                    //MARK: - Bottom-right arrow
                    
                    Image("arrow.bottom.right")
                        .resizable()
                        .font(.system(size: 12))
                        .frame(width: 50, height: 50)
                        .foregroundColor(.white)
                        .offset(x: (bottomRightOffset.width) + (bottomRightMagnification.width * cropSize.width) / 2,
                                y: (bottomRightOffset.height) + (bottomRightMagnification.height * cropSize.height) / 2)
                        .gesture(DragGesture().onChanged({ gesture in
                            bottomRightSideIsActive = true
                            topRightSideIsActive = false
                            topLeftSideIsActive = false
                            bottomLeftSideIsActive = false
                            
                            croppingVM.side = .bottomRight
                            
                            //Get offset drag gesture
                            xBottomRightOffset = gesture.translation.width + lastBottomRightOffset.width
                            yBottomRightOffset = gesture.translation.height + lastBottomRightOffset.height
                            
                            //Get the ratio of crop magnification
                            bottomRightMagnification = croppingVM.getMagnification(xOffset: xBottomRightOffset,
                                                                                   yOffset: yBottomRightOffset, cropSize: cropSize)
                            
                            //Add limit when reducing
                            bottomRightMagnification = croppingVM.addReducingLimit(magnification: bottomRightMagnification,
                                                                                   xLastOpposedMagnification: lastBottomLeftMagnification.width,
                                                                                   yLastOpposedMagnification: lastTopRightMagnification.height)
                            
                            //Add edges limit
                            bottomRightMagnification = croppingVM.addEdgesLimit(xOffset: xBottomRightOffset,
                                                                                yOffset: yBottomRightOffset,
                                                                                magnification: bottomRightMagnification, imageSize: imageSize, cropSize: cropSize)
                            
                            //Get offset
                            bottomRightOffset = croppingVM.changeOffsetSize(magnification: bottomRightMagnification,
                                                                            lastMagnification: lastBottomRightMagnification,
                                                                            finalOffset: finalBottomRightOffset, cropSize: cropSize)
                            
                            //Set magnification and offset that are common in x
                            topRightMagnification.width = bottomRightMagnification.width
                            topRightOffset.width = bottomRightOffset.width
                            
                            //Set magnification and offset that are common in y
                            bottomLeftMagnification.height = bottomRightMagnification.height
                            bottomLeftOffset.height = bottomRightOffset.height
                            
                        }).onEnded({ _ in
                            bottomRightSideIsActive = false
                            topRightSideIsActive = false
                            topLeftSideIsActive = false
                            bottomLeftSideIsActive = false
                            //Store last offset and last limit reducing gesture
                            lastBottomRightOffset = croppingVM.storeLastGesture(xOffset: xBottomRightOffset,
                                                                                yOffset: yBottomRightOffset,
                                                                                magnification: bottomRightMagnification,
                                                                                xLastOpposedMagnification: lastBottomLeftMagnification.width,
                                                                                yLastOpposedMagnification: lastTopRightMagnification.height,
                                                                                xLastOpposedOffset: lastBottomLeftOffset.width,
                                                                                yLastOpposedOffset: lastTopRightOffset.height, cropSize: cropSize)
                            
                            //Store last offset if offset is in limit edges
                            lastBottomRightOffset = croppingVM.storeLastLimitEdges(xOffset: xBottomRightOffset,
                                                                                   yOffset: yBottomRightOffset,
                                                                                   lastOffset: lastBottomRightOffset, imageSize: imageSize, cropSize: cropSize)
                            
                            //Store last magnification and finial offset, it's used for crop calculations
                            lastBottomRightMagnification = bottomRightMagnification
                            finalBottomRightOffset = bottomRightOffset
                            
                            //Store magnification and offset that are common in x
                            lastTopRightMagnification.width = lastBottomRightMagnification.width
                            lastTopRightOffset.width = lastBottomRightOffset.width
                            finalTopRightOffset.width = bottomRightOffset.width
                            
                            //Store magnification and offset that are common in y
                            lastBottomLeftMagnification.height = lastBottomRightMagnification.height
                            lastBottomLeftOffset.height = lastBottomRightOffset.height
                            finalBottomLeftOffset.height = bottomRightOffset.height
                            
                            cropImage()
                            
                        }))
                        .disabled(topLeftSideIsActive || topRightSideIsActive || bottomLeftSideIsActive || isPerformingAnimation)
                }
            }
            
        }
        .onChange(of: isEditing, perform: { _ in
            resetVariables()
        })
    }
    
    func getCroppRectOffset()->CGSize{
        
        let xOffset = croppingVM.side.sides.1 ? topLeftOffset.width + finalTopRightOffset.width : topRightOffset.width + finalTopLeftOffset.width
        let yOffset = croppingVM.side.sides.0 ? topLeftOffset.height + finalBottomLeftOffset.height: bottomLeftOffset.height + finalTopLeftOffset.height
        return CGSize(width: xOffset, height: yOffset)
    }
    
    func getCroppRectFrame(cropSize: CGFloat)->CGSize{
        
        let widthFrame = croppingVM.side.sides.1 ? (cropSize) * ((topLeftMagnification.width + lastTopRightMagnification.width) - 1):
        (cropSize) * ((topRightMagnification.width + lastTopLeftMagnification.width) - 1)
        let heightFrame = croppingVM.side.sides.0 ? (cropSize) * ((topLeftMagnification.height + lastBottomLeftMagnification.height) - 1) :
        (cropSize) * ((bottomLeftMagnification.height + lastTopLeftMagnification.height) - 1)
        
        return CGSize(width: widthFrame, height: heightFrame)
    }
    
    func cropImage(){
        croppedImage = croppingVM.cropImage(
            originalImage: originalImage!, lastOffset: lastTopLeftOffset,
            lastMagnification: lastTopLeftMagnification,
            xLastOppositeMagnification: lastTopRightMagnification.width,
            yLastOppositeMagnification: lastBottomLeftMagnification.height, imageSize: imageSize, cropSize: cropSize)!
        
        
        //Animation forground color black
        withAnimation(.easeIn(duration: 0.5)){
            isPerformingAnimation = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now()+0.6, execute: {
            
            withAnimation(.spring(response: 0.3).speed(0.8)){
                isEditing.toggle()
                originalImage = croppedImage!
                isShowingCroppedImage.toggle()
                resetVariables()
                isPerformingAnimation = false
            }
        })
        
    }
    
    func resetVariables(){
        topLeftMagnification = CGSize(width: 1.0, height: 1.0)
        topRightMagnification = CGSize(width: 1.0, height: 1.0)
        bottomLeftMagnification = CGSize(width: 1.0, height: 1.0)
        bottomRightMagnification = CGSize(width: 1.0, height: 1.0)
        
        lastTopLeftMagnification = CGSize(width: 1.0, height: 1.0)
        lastTopRightMagnification = CGSize(width: 1.0, height: 1.0)
        lastBottomLeftMagnification = CGSize(width: 1.0, height: 1.0)
        lastBottomRightMagnification = CGSize(width: 1.0, height: 1.0)
        
        finalTopLeftOffset = CGSize(width: 0.0, height: 0.0)
        finalTopRightOffset = CGSize(width: 0.0, height: 0.0)
        finalBottomLeftOffset = CGSize(width: 0.0, height: 0.0)
        finalBottomRightOffset = CGSize(width: 0.0, height: 0.0)
        
        lastTopLeftOffset = CGSize(width: 0.0, height: 0.0)
        lastTopRightOffset = CGSize(width: 0.0, height: 0.0)
        lastBottomLeftOffset = CGSize(width: 0.0, height: 0.0)
        lastBottomRightOffset = CGSize(width: 0.0, height: 0.0)
        
        topLeftOffset = CGSize(width: 0.0, height: 0.0)
        topRightOffset = CGSize(width: 0.0, height: 0.0)
        bottomLeftOffset = CGSize(width: 0.0, height: 0.0)
        bottomRightOffset = CGSize(width: 0.0, height: 0.0)
    }
}

struct CroppingView_Previews: PreviewProvider {
    static var previews: some View {
        CroppingView(originalImage: .constant(UIImage(named: "Image")), isEditing: .constant(true))
    }
}

