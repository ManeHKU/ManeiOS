//
//  HomeView.swift
//  Mane HKU
//
//  Created by Yau Chin Pang on 11/1/2024.
//

import SwiftUI
import AlertToast

struct HomeView: View {
    @Bindable private var homeVM: HomeViewModel = HomeViewModel()
    
    var body: some View {
        VStack {
            Text("Hello \(homeVM.nickname)")
            if homeVM.userInfo != nil {
                Text("Your name: \(homeVM.userInfo?.fullName ?? "Empty")")
                Text("Your UID: \(homeVM.userInfo?.uid ?? 0)")
            }
            
            Button("Update info") {
                Task {
                    await homeVM.updateUserInfo()
                }
            }
            
            Button("Sign out") {
                Task {
                    try! await UserManager.shared.supabase.auth.signOut()
                }
            }
            .navigationTitle("Home")
            .navigationBarBackButtonHidden()
        }
        .toast(isPresenting: $homeVM.loading) {
            AlertToast(displayMode: .alert, type: .loading)
        }
        .toast(isPresenting: $homeVM.updated) {
            AlertToast(displayMode: .alert, type: .complete(.green), title: "Success", subTitle: "Updated User Info")
        }
        .toast(isPresenting: $homeVM.errorExists) {
            AlertToast.createErrorToast(title: "Error", subtitle: homeVM.error)
        }
        .onAppear {
            Task {
                await homeVM.initialLoginToSIS()
            }
        }
    }
}

#Preview {
    HomeView()
}
