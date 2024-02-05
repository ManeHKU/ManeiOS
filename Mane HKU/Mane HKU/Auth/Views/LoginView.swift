//
//  LoginView.swift
//  Mane HKU
//
//  Created by Yau Chin Pang on 13/1/2024.
//

import SwiftUI
import AlertToast

struct LoginView: View {
    @Bindable private var loginVM: LoginViewModel = LoginViewModel()
    
    var body: some View {
        NavigationStack {
            ZStack {
                BackgroundAuthView()
                VStack {
                    Spacer()
                    VStack {
                        Text("Enter your HKU Portal ID & password.")
                            .fixedSize(horizontal: false, vertical: /*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/)
                            .font(.callout)
                            .padding(.bottom, 10)
                        loginFields
                        
                        loginButton
                    }
                    Spacer()
                }
                .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, maxHeight: .infinity, alignment: .topLeading)
                .padding()
                .background(.thinMaterial)
            }
            .navigationTitle("Login")
            .navigationDestination(isPresented: $loginVM.loggedIn) {
                HomeView()
            }
        }
        .errorToast(title: loginVM.loginErrorToast.title, subtitle: loginVM.loginErrorToast.subtitle, trigger: $loginVM.loginErrorToast.show)
        .toast(isPresenting: $loginVM.loading) {
            AlertToast(type: .loading)
        }
    }
    
    var loginFields: some View {
        VStack(alignment:.leading) {
            Text("Portal ID:")
            TextField("e.g. u353xxxxx", text: $loginVM.portalId)
                .textContentType(.username)
                .textInputAutocapitalization(.never)
                .disabled(loginVM.loading)
            
            Text("Password:")
            SecureField("", text: $loginVM.password)
                .textContentType(.password)
                .disabled(loginVM.loading)
        }
        .textFieldStyle(.roundedBorder)
    }
    
    var loginButton: some View {
        NavigationLink(value: "login", label: {
            Button {
                Task {
                    await loginVM.loginUser()
                }
            } label: {
                HStack{
                    Text("Login")
                    Image(systemName: "paperplane.fill")
                        .font(.title2)
                }
                .padding(.vertical, 5)
                .padding(.horizontal, 60)
            }
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.capsule)
        })
        .disabled(!loginVM.loginFieldsValid || loginVM.loading)
        .padding(.vertical, 10)
    }
}

#Preview {
    LoginView()
}
