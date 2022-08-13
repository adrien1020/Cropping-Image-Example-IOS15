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
    var body: some View{
        ZStack{
            Color.black
            VStack{
                CroppingView(originalImage: $originalImage, isEditing: $isEditing)
                HStack{
                    if isEditing{
                        Spacer()
                        Button(action: {
                            withAnimation{
                                self.isEditing = false
                            }
                        }, label: {
                            Text("Annuler")
                                .foregroundColor(Color.white)
                        })
                        Spacer()
                    }
                    Spacer()
                    Button(action: {
                        isOpenningImagePicker.toggle()
                        withAnimation{
                            self.isEditing = false
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
                            self.isEditing.toggle()
                        }
                    }, label: {
                        Image(systemName: "crop")
                            .font(.system(size: 24))
                            .foregroundColor(.white)
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
        }
        
        .onChange(of: inputImage, perform: { _ in
            loadImage()
        })
        
        .sheet(isPresented: $isOpenningImagePicker, content: {
            ImagePickerView(image: $originalImage)
        })
        .background(Color.black)
    }
    
    func loadImage(){
        guard let inputImage = inputImage else {return}
        originalImage = inputImage
        
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        CroppingView(originalImage: .constant(UIImage(named: "Image")), isEditing: .constant(true))
    }
}
