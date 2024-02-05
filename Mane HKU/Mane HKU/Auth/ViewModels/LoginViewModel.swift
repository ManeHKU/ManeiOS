//
//  LoginViewModel.swift
//  Mane HKU
//
//  Created by Yau Chin Pang on 20/1/2024.
//

import Foundation
import os

@Observable class LoginViewModel {
    var portalId: String = ""
    var password: String = ""
    var loading = false
    
    var loginFieldsValid: Bool {
        isPortalIdValid(portalId) && isPasswordValid(password)
    }
    
    var loggedIn = false
    var loginErrorToast: ToastMessage = ToastMessage(show: false, title: "", subtitle: nil)
    
    func loginUser() async {
        defer {loading = false}
        loading = true
        let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: (String(describing: self)))
        if !loginFieldsValid {
            loginErrorToast.title = "Unknown Error"
            loginErrorToast.subtitle = "Try again"
            loginErrorToast.show = true
            return
        }
        
        do {
            logger.info("starting supabase sign in")
            try await UserManager.shared.supabase.auth.signIn(
                email: "\(portalId)@connect.hku.hk",
                password: password)
            logger.info("finished supabase sign in")
            KeychainManager.shared.secureSave(key: .PortalId, value: portalId)
            KeychainManager.shared.secureSave(key: .PortalPassword, value: password)
            loggedIn = true
        } catch {
            logger.error("\(error.localizedDescription)")
            loginErrorToast.title = error.localizedDescription
            loginErrorToast.subtitle = nil
            loginErrorToast.show = true
        }
    }
}
