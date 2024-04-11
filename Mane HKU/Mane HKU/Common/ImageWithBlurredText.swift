//
//  ImageWithBlurredText.swift
//  Mane HKU
//
//  Created by Yau Chin Pang on 10/4/2024.
//

import SwiftUI

struct ImageWithBlurredText: View {
    let image: Image?
    let text: String
    var textColor: Color = .primary
    var body: some View {
        ZStack(alignment: .bottom) {
            if let image = image {
                image
                    .resizable()
                    .scaledToFill()
                        
                //From: https://www.reddit.com/r/SwiftUI/comments/o8d8ju/blur_with_gradient_edges/
                Rectangle()
                    .fill(.thinMaterial)
                    .frame(height: 90)
                    .mask {
                        VStack(spacing: 0) {
                            LinearGradient(colors: [Color.black.opacity(0),  // sin(x * pi / 2)
                                                    Color.black.opacity(0.383),
                                                    Color.black.opacity(0.707),
                                                    Color.black.opacity(0.924),
                                                    Color.black],
                                           startPoint: .top,
                                           endPoint: .bottom)
                            .frame(height: 40)
                            Rectangle()
                        }
                    }
                Text(text)
                    .font(.headline)
                    .bold()
                    .padding(.all, 20)
                    .foregroundStyle(textColor)
                    .multilineTextAlignment(.center)
            } else {
                ProgressView()
            }
        }
    }
}

#Preview {
    ImageWithBlurredText(image: Image("Test2"), text: "Espresso Tasting Competition", textColor: .pink)
        .frame(height: 100)
}
