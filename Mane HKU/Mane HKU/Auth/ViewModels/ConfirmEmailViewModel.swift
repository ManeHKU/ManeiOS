//
//  ConfirmEmailViewModel.swift
//  Mane HKU
//
//  Created by Yau Chin Pang on 11/1/2024.
//


import Foundation
import Observation
import os

@Observable class ConfirmEmailViewModel {
    @ObservationIgnored private let loginDetails: PortalLoginDetails
    
    init(loginDetails: PortalLoginDetails) {
        self.loginDetails = loginDetails
    }
    var otpCode = ""
    var goodToast = ToastMessage(show: false, title: "", subtitle: nil)
    var errorToast = ToastMessage(show: false, title: "", subtitle: nil)
    
    var showSuccessPage = false
    var showVerifySuccessAlert = false
    
    
    func resendCode(with userManager: UserManager) async {
        let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: (String(describing: self)))
        do{
            print("resend code")
            try await userManager.supabase.auth.resend(email: "\(loginDetails.portalId)@connect.hku.hk", type: .signup)
            goodToast.title = "Email has been resent"
            goodToast.subtitle = "Check your inbox"
            goodToast.show = true
        } catch {
            logger.error("resend failed for \(self.loginDetails.portalId), error: \(error.localizedDescription)")
            errorToast.title = error.localizedDescription
            errorToast.subtitle = "Try again later"
            errorToast.show = true
        }
    }
    
    func submitCode(with userManager: UserManager) async {
        let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: (String(describing: self)))
        do{
            try await userManager.supabase.auth.verifyOTP(email: "\(loginDetails.portalId)@connect.hku.hk", token: otpCode, type: .signup)
            logger.info("otp correct")
            KeychainManager.shared.secureSave(key: .PortalId, value: loginDetails.portalId)
            KeychainManager.shared.secureSave(key: .PortalPassword, value: loginDetails.password)
            showVerifySuccessAlert = true
            try await Task.sleep(nanoseconds: UInt64(3 * Double(NSEC_PER_SEC)))
            showSuccessPage = true
        } catch {
            logger.error("failed to verify code for \(self.loginDetails.portalId), error: \(error.localizedDescription)")
            errorToast.title = error.localizedDescription
            errorToast.subtitle = nil
            errorToast.show = true
        }
    }
}
