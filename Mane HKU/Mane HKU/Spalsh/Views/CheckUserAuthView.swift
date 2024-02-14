//
//  CheckUserAuthViewswift.swift
//  Mane HKU
//
//  Created by Yau Chin Pang on 15/1/2024.
//

import SwiftUI
import AlertToast
import Supabase

struct SplashView: View {
    @State private var isLoading = true
    @EnvironmentObject private var appRootManager: AppRootManager
    
    var body: some View {
        ZStack {
            BackgroundAuthView()
        }.onAppear {
            Task {
                let isTokenValid = await UserManager.shared.checkLocalTokenValid()
                isLoading = false
                if isTokenValid {
                    appRootManager.currentRoot = .home
                } else {
                    appRootManager.currentRoot = .authentication
                }
            }
        }
        .toast(isPresenting: $isLoading) {
            AlertToast(displayMode: .alert, type: .loading)
        }
        
    }
}

#Preview {
    SplashView()
}
