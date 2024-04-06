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
    @EnvironmentObject private var appRootManager: AppRootManager
    @State private var loading = false
    
    var body: some View {
        ZStack {
            BackgroundAuthView()
                .toast(isPresenting: $loading) {
                    AlertToast(displayMode: .alert, type: .loading)
                }
        }.onAppear {
            loading = true
            Task {
                let isTokenValid = await UserManager.shared.checkLocalTokenValid()
                loading = false
                if isTokenValid {
                    appRootManager.currentRoot = .home
                } else {
                    appRootManager.currentRoot = .authentication
                }
            }
        }
    }
}

#Preview {
    SplashView()
}
