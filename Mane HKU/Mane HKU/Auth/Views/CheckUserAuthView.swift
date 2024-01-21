//
//  CheckUserAuthViewswift.swift
//  Mane HKU
//
//  Created by Yau Chin Pang on 15/1/2024.
//

import SwiftUI
import AlertToast
import Supabase

struct CheckUserAuthView: View {
    @State private var isLoading = true
    @State private var showAuthSetup = false
    @State private var showHome = false
    @State private var userManager: UserManager = UserManager()
    
    var body: some View {
        NavigationStack {
            ZStack {
                BackgroundAuthView()
            }.onAppear {
                Task {
                    let isTokenValid = await userManager.checkLocalTokenValid()
                    isLoading = false
                    if isTokenValid {
                        showHome = true
                    } else {
                        showAuthSetup = true
                    }
                }
            }
            .navigationDestination(isPresented: $showAuthSetup) {
                AuthSetupView()
            }
            .navigationDestination(isPresented: $showHome) {
                HomeView()
            }
        }
        .environment(userManager)
        .toast(isPresenting: $isLoading) {
            AlertToast(displayMode: .alert, type: .loading)
        }
        
    }
}

#Preview {
    CheckUserAuthView()
}
