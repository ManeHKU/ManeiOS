//
//  Mane_HKUApp.swift
//  Mane HKU
//
//  Created by Yau Chin Pang on 10/12/2023.
//

import SwiftUI

@main
struct ManeHKUApp: App {
    @State private var appRootManager = AppRootManager()
    var body: some Scene {
        WindowGroup {
            Group {
                switch appRootManager.currentRoot {
                case .splash:
                    SplashView()
                    
                case .authentication:
                    AuthSetupView().transition(.slide)
                    
                case .home:
                    MainTabView().transition(.slide)
                }
            }
            .environmentObject(appRootManager)
        }
    }
}
