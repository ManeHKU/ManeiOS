//
//  ConfirmEmailView.swift
//  Mane HKU
//
//  Created by Yau Chin Pang on 10/1/2024.
//

import SwiftUI
import AlertToast

struct ConfirmEmailView: View {
    @Environment(UserManager.self) private var userManager
    @Bindable private var confirmEmailVM: ConfirmEmailViewModel
    init(loginDetails: PortalLoginDetails) {
        confirmEmailVM = ConfirmEmailViewModel(loginDetails: loginDetails)
    }
    @FocusState private var focusedField: Bool
    @State private var secondsRemaining = 60
    
    @State private var loading = false
    
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    let otpLimit = 6
    
    var body: some View {
        NavigationStack {
            ZStack {
                BackgroundAuthView()
                VStack(spacing: 10) {
                    TextField("", text: $confirmEmailVM.otpCode)
                        .textFieldStyle(.plain)
                        .multilineTextAlignment(.center)
                        .keyboardType(.numberPad)
                        .textContentType(.oneTimeCode)
                        .kerning(10)
                        .padding(20)
                        .font(.title3)
                        .foregroundStyle(.primary)
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now()+0.2) {
                                focusedField = true
                            }
                        }
                        .onChange(of: confirmEmailVM.otpCode) { oldValue, newValue in
                            if newValue.allSatisfy({"0123456789".contains($0)}) {
                                if newValue.count != 6 {
                                    confirmEmailVM.otpCode = String(newValue.prefix(otpLimit))
                                    return
                                }
                                print("submitting code")
                                loading = true
                                Task {
                                    await confirmEmailVM.submitCode(with: userManager)
                                    loading = false
                                    if !confirmEmailVM.showSuccessPage {
                                        focusedField = true
                                        return
                                    }
                                }
                                
                            } else {
                                confirmEmailVM.otpCode = oldValue
                            }
                        }
                        .focused($focusedField)
                        .disabled(loading)
                        .toolbar {
                            ToolbarItemGroup(placement: .keyboard) {
                                Button(secondsRemaining == 0 ? "Resend code" : "Resend code after \(secondsRemaining) seconds") {
                                    if secondsRemaining == 0 {
                                        Task {
                                            await confirmEmailVM.resendCode(with: userManager)
                                            secondsRemaining = 60
                                        }
                                    }
                                }
                                .disabled(secondsRemaining > 0)
                                .onReceive(timer) { _ in
                                    if secondsRemaining > 0 {
                                        secondsRemaining -= 1
                                    }
                                }
                            }
                        }
                    
                    Text("Find your 6 digit code in your connect email")
                        .font(.title)
                        .multilineTextAlignment(.center)
                    Text("You may need to check your junk mail as well")
                        .font(.callout)
                        .multilineTextAlignment(.center)
                }
                .goodToast(title: confirmEmailVM.goodToast.title, subtitle: confirmEmailVM.goodToast.subtitle, trigger: $confirmEmailVM.goodToast.show)
                .errorToast(title: confirmEmailVM.errorToast.title, subtitle: confirmEmailVM.errorToast.subtitle, trigger: $confirmEmailVM.errorToast.show)
                .toast(isPresenting: $loading){
                    AlertToast(type: .loading)
                }
                .toast(isPresenting: $confirmEmailVM.showVerifySuccessAlert, duration: 3.0, tapToDismiss: false) {
                    AlertToast(displayMode: .alert, type: .complete(.accentColor))
                }
                .padding(.horizontal, 25)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(.thinMaterial)
                .navigationDestination(isPresented: $confirmEmailVM.showSuccessPage) {
                    HomeView()
                }
            }
            .navigationTitle("Confirm email")
            .navigationBarBackButtonHidden()
        }
    }
}

#Preview {
    ConfirmEmailView(loginDetails: PortalLoginDetails(portalId: "yaucp", password: "82027292Hku"))
}

