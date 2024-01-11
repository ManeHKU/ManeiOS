//
//  AuthSetupView.swift
//  Mane HKU
//
//  Created by Yau Chin Pang on 4/1/2024.
//

import SwiftUI
import Supabase
import AlertToast

struct SignUpView: View {
    @Environment(\.colorScheme) var colorScheme
    @Bindable private var signUpVM = SignUpViewModel()
    
    @State private var showSecurityInfo = false
    @State private var showHaveAccountAlert = false
    @Environment(\.presentationMode) private var presentationMode
    
    var body: some View {
        NavigationStack {
            ZStack {
                BackgroundAuthView()
                
                VStack {
                    ScrollView {
                        Text("In order to use Mane, we would like to ask for your HKU Portal ID and password to proceed.")
                            .fixedSize(horizontal: false, vertical: /*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/)
                            .font(.callout)
                            .padding(.bottom, 10)
                        
                        loginFields
                        
                        signUpButton
                        
                        disclaimer
                    }
                }
                .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, maxHeight: .infinity, alignment: .topLeading)
                .padding()
                .background(.thinMaterial)
            }
            .navigationTitle("Setup")
            .navigationDestination(isPresented: $signUpVM.showVerifyEmailView, destination: {
                let loginDetails = PortalLoginDetails(portalId: signUpVM.portalId, password: signUpVM.password)
                ConfirmEmailView(loginDetails: loginDetails)
            })
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
        .errorToast(title: signUpVM.signUpErrorToast.title, subtitle: signUpVM.signUpErrorToast.subtitle, trigger: $signUpVM.signUpErrorToast.show)
        .toast(isPresenting: $signUpVM.loading) {
            AlertToast(type: .loading)
        }
        .toast(isPresenting: $signUpVM.shouldPopView, duration: 5.0 ,tapToDismiss: false, alert: {
            AlertToast(displayMode: .alert, type: .error(.red), title: "You have an account already", subTitle: "Please login instead")
        }, completion: {
            presentationMode.wrappedValue.dismiss()
        })
    }
    
    var signUpButton: some View {
        NavigationLink(value: "signUp", label: {
            Button {
                Task {
                    await signUpVM.signUpUser()
                }
            } label: {
                HStack{
                    Text("Sign Up")
                    Image(systemName: "applepencil.and.scribble")
                        .font(.title2)
                }
                .padding(.vertical, 5)
                .padding(.horizontal, 60)
            }
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.capsule)
        })
        .disabled(!signUpVM.signUpFieldsValid || signUpVM.loading)
        .padding(.vertical, 10)
    }
    
    var disclaimer: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Your credentails are stored securely and we would only use it to access information on your account.")
                .fixedSize(horizontal: false, vertical: /*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/)
                .foregroundStyle(colorScheme == .dark ? .cyan : .indigo)
            Button(action: {
                showSecurityInfo.toggle()
            }, label: {
                Image(systemName: "lock")
                Text("How do we protect your data")
            })
            .buttonStyle(.borderless)
            .buttonBorderShape(.roundedRectangle)
        }
    }
    
    var loginFields: some View {
        VStack(alignment:.leading) {
            Text("Nickname:")
            TextField("e.g. Frederick", text: $signUpVM.nickname, prompt: Text("e.g. Tim"))
                .textContentType(.nickname)
                .disabled(signUpVM.loading || signUpVM.shouldPopView)
            PromptText(promptWordings: signUpVM.nicknamePrompt, input: signUpVM.nickname)
            
            Text("Portal ID:")
            TextField("e.g. u353xxxxx", text: $signUpVM.portalId)
                .textContentType(.username)
                .textInputAutocapitalization(.never)
                .disabled(signUpVM.loading || signUpVM.shouldPopView)
            PromptText(promptWordings: signUpVM.portalIdPrompt, input: signUpVM.portalId)
            
            Text("Password:")
            SecureField("", text: $signUpVM.password)
                .textContentType(.password)
                .disabled(signUpVM.loading || signUpVM.shouldPopView)
            PromptText(promptWordings: signUpVM.passwordPrompt, input: signUpVM.password)
        }
        .textFieldStyle(.roundedBorder)
    }
}

struct PromptText: View {
    var promptWordings: String
    var input: String
    var body: some View {
        if !promptWordings.isEmpty && !input.isEmpty {
            Text(promptWordings)
                .foregroundStyle(.secondary)
                .font(.callout)
                .padding(.bottom, 5)
        }
        
    }
}

#Preview {
    SignUpView()
}
