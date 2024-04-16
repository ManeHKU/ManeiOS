//
//  MainTabView.swift
//  Mane HKU
//
//  Created by Yau Chin Pang on 6/2/2024.
//

import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
            
            GPTView()
                .tabItem {
                    Label("Assistant", systemImage: "sparkles")
                }
        }
    }
}

#Preview {
    MainTabView()
}
