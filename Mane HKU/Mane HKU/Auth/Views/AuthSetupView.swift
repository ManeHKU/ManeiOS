//
//  AuthSetupView.swift
//  Mane HKU
//
//  Created by Yau Chin Pang on 5/1/2024.
//

import SwiftUI

struct AuthSetupView: View {
    var body: some View {
        NavigationStack {
            ZStack{
                Rectangle()
                    .fill(
                        LinearGradient(gradient:
                                        Gradient(colors: [ .blue,.green, .accentColor]), startPoint: .topLeading, endPoint: .bottomTrailing))
                
                    .ignoresSafeArea()
                VStack {
                    Spacer()
                    VStack(alignment: .leading) {
                        Text("Welcome to Mane")
                            .font(.largeTitle)
                            .bold()
                        Text("You are not logged in yet.")
                            .font(.title2)
                    }
                    .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .leading)
                    .padding(20)
                    .foregroundColor(.white)
                    Spacer()
                    VStack{
                        NavigationLink{
                            SignUpView()
                        } label:{
                            Text("Sign Up")
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 5)
                        }
                        .foregroundColor(/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/)
                        .buttonStyle(.borderedProminent)
                        .tint(.blueishWhite)
                        
                        NavigationLink {
                            // temp
                        } label:{
                            Text("Login")
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 5)
                        }
                        .foregroundColor(.blueishWhite)
                        .tint(.white)
                        .buttonStyle(.bordered)
                    }
                    .buttonBorderShape(.capsule)
                    .padding(20)
                }
            }
            .navigationTitle("Welcome")
            .navigationBarHidden(true)
            
        }
    }
}

#Preview {
    AuthSetupView()
}

