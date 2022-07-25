//
//  CroppedImage.swift
//  Cropping Image Example
//
//  Created by Adrien Surugue on 23/07/2022.
//

import SwiftUI

struct CroppedImage: View {
    
    var image: UIImage
    
    var body: some View {
        ZStack{
            Color.black
        Image(uiImage: image)
            .resizable()
            .aspectRatio(contentMode: .fit)
        }
        .ignoresSafeArea()
    }
}

