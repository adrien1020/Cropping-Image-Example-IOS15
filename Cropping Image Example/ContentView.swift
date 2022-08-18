//
//  ContentView.swift
//  Cropping Image Example
//
//  Created by Adrien Surugue on 16/07/2022.
//

import SwiftUI

struct ContentView: View{
    
    @State private var isEditing = false
    @State private var isOpenningImagePicker = false
    @State var originalImage: UIImage?
    @State private var inputImage: UIImage?
    @State private var savedImage: UIImage?
    var body: some View{
        ZStack{
            Color.black
            VStack{
                HStack{
                    if originalImage != savedImage && !isEditing{
                        Button(action: {
                            originalImage = savedImage
                        }, label: {
                            Text("Réinit")
                                .foregroundColor(.yellow)
                        })
                    }
                }
                .frame(width: UIScreen.main.bounds.width, height: 20, alignment: .center)
                CroppingView(originalImage: $originalImage, isEditing: $isEditing)
                HStack{
                   
                    Spacer()
                    Button(action: {
                        isOpenningImagePicker.toggle()
                        withAnimation{
                            isEditing = false
                        }
                    }, label: {
                        Image(systemName: "photo")
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                    })
                    .buttonStyle(.bordered)
                    .tint(.gray)
                    Spacer()
                    Button(action: {
                        withAnimation{
                            isEditing.toggle()
                        }
                    }, label: {
                        Image(systemName: "crop")
                            .font(.system(size: 24))
                            .foregroundColor(isEditing ? .yellow : .white)
                    })
                    .buttonStyle(.bordered)
                    .tint(.gray)
                    Spacer()
                }
                .frame(width: UIScreen.main.bounds.width, height: 40)
                
                .padding()
                .padding(.bottom, 20)
            }
        }
        .onAppear(){
            originalImage = UIImage(named: "Image")
            savedImage = originalImage
        }
        .onChange(of: inputImage, perform: { _ in
            loadImage()
        })
        .sheet(isPresented: $isOpenningImagePicker, content: {
            ImagePickerView(image: $inputImage)
        })
        .background(Color.black)
    }
    
    func loadImage(){
        guard let inputImage = inputImage else {return}
        originalImage = inputImage
        savedImage = inputImage
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        CroppingView(originalImage: .constant(UIImage(named: "Image")), isEditing: .constant(true))
    }
}
