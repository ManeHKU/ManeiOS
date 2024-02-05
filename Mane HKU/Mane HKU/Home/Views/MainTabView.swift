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
            
            Text("testy boi")
                .tabItem {
                    Label("Test", systemImage: "testtube.2")
                }
        }
    }
}

#Preview {
    MainTabView()
}
