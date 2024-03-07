//
//  SettingsView.swift
//  Mane HKU
//
//  Created by Yau Chin Pang on 6/3/2024.
//

import SwiftUI


struct SettingsView: View {
    @EnvironmentObject private var appRootManager: AppRootManager
    var body: some View {
        Button("Logout", systemImage: "rectangle.portrait.and.arrow.right") {
            Task {
                do{
                    try await UserManager.shared.supabase.auth.signOut()
                    appRootManager.currentRoot = .authentication
                } catch {
                    print("failed to sign out")
                }
            }
        }
    }
}

#Preview {
    SettingsView()
}
