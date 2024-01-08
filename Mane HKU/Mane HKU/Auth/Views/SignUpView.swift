//
//  AuthSetupView.swift
//  Mane HKU
//
//  Created by Yau Chin Pang on 4/1/2024.
//

import SwiftUI
import Supabase

// swiftlint:disable:next line_length


struct SignUpView: View {
    @Bindable var signUpVM = SignUpViewModel()
    
    @State private var showSecurityInfo = false
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("In order to use Mane, we would like to ask for your HKU Portal ID and password to proceed.")
                    .fixedSize(horizontal: false, vertical: /*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/)
                    .font(.title3)
                    .padding(.bottom, 10)
                
                loginFields
                
                signUpButton
                
                disclaimer
            }
            .navigationTitle("Setup")
            .padding()
            .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, maxHeight: .infinity, alignment: .topLeading)
        }
        .sheet(isPresented: $showSecurityInfo, content: {
            VStack(spacing: 30){
                Image(systemName: "lock.shield")
                    .imageScale(.large)
                    .font(.system(size: 80))
                    .foregroundStyle(.red)
                Text("Please be ensured that your credentials are stored securely with [Apple's Keychain technology locally](https://developer.apple.com/documentation/security/keychain_services/) and an established remote service with proper encryption after you have finished setting up.")
            }
            .padding(20)
            .presentationBackground(.thinMaterial)
            .presentationDetents([.medium])
        })
    }
    
    var signUpButton: some View {
        Button(action: {
            Task {
                do {
                    print(try await client.auth.signUp(
                        email: "\(signUpVM.portalId)@connect.hku.hk",
                        password: "123456789A"))
                } catch {
                    print(error)
                }
            }
        }) {
            HStack{
                Text("Sign Up")
                Image(systemName: "applepencil.and.scribble")
                    .font(.title2)
            }
            .padding(.vertical, 5)
            .padding(.horizontal, 60)
        }
        .padding(.vertical, 10)
        .buttonBorderShape(.capsule)
        .buttonStyle(.borderedProminent)
        .disabled(!signUpVM.signUpFieldsValid)
    }
    
    var disclaimer: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("It is impossible for us to access your information as we do not have access to your credentials.")
                .foregroundStyle(.red)
                .fixedSize(horizontal: false, vertical: /*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/)
            Button(action: {
                showSecurityInfo.toggle()
            }, label: {
                Image(systemName: "lock")
                Text("How do we protect your data")
            })
            .foregroundStyle(.blue)
            .buttonStyle(.borderless)
            .buttonBorderShape(.roundedRectangle)
        }
    }
    
    var loginFields: some View {
        VStack(alignment:.leading) {
            Text("Nickname:")
            TextField("e.g. Frederick", text: $signUpVM.nickname, prompt: Text(signUpVM.nicknamePrompt))
                .textContentType(.nickname)
            
            Text("Portal ID:")
            TextField("e.g. u353xxxxx", text: $signUpVM.portalId)
                .textContentType(.username)
                .textInputAutocapitalization(.never)
            
            Text("Password:")
            SecureField("Enter your password", text: $signUpVM.password)
                .textContentType(.password)
        }.textFieldStyle(.roundedBorder)
    }
}

#Preview {
    SignUpView()
}
