//
//  HomeView.swift
//  Mane HKU
//
//  Created by Yau Chin Pang on 11/1/2024.
//

import SwiftUI

struct HomeView: View {
    @Environment(UserManager.self) private var userManager
    @Bindable private var homeVM: HomeViewModel = HomeViewModel()
    
    var body: some View {
        VStack {
            Text("Hello, Home!")
            if homeVM.userInfo != nil {
                Text("Your name: \(homeVM.userInfo?.fullName ?? "Empty")")
                Text("Your UID: \(homeVM.userInfo?.uid ?? 0)")
            }
            
            Button("Sign out") {
                Task {
                    try! await userManager.supabase.auth.signOut()
                }
            }
            .navigationBarBackButtonHidden()
        }.onAppear {
            Task {
                await homeVM.initialLoginToSIS(using:userManager)
            }
        }
        
    }
}

#Preview {
    HomeView()
}
