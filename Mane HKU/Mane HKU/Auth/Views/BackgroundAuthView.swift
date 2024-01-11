//
//  BackgroundView.swift
//  Mane HKU
//
//  Created by Yau Chin Pang on 9/1/2024.
//

import SwiftUI

struct BackgroundAuthView: View {
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        Rectangle()
            .fill(
                LinearGradient(gradient:
                                Gradient(colors: [ .blue,.green, .accentColor]), startPoint: .topLeading, endPoint: .bottomTrailing))
        
            .ignoresSafeArea()
            .opacity(colorScheme == .dark ? 0.9 : 1)
    }
}
