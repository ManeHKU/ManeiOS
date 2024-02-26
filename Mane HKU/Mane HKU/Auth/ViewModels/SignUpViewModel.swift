//
//  SignUpViewModel.swift
//  Mane HKU
//
//  Created by Yau Chin Pang on 6/1/2024.
//

import Foundation
import Observation
import os

@Observable class SignUpViewModel {
    var nickname: String = ""
    var portalId: String = ""
    var password: String = ""

    var loading = false
    var showErrorMessage = false
    var showVerifyEmailView = false
    var signUpErrorToast: ToastMessage = ToastMessage(show: false, title: "", subtitle: nil)
    
    var shouldPopView = false
    
    var signUpFieldsValid: Bool {
        isNicknameValid(nickname) && isPortalIdValid(portalId) && isPasswordValid(password)
    }
    
    var nicknamePrompt: String {
        if isNicknameValid(nickname) {
            return ""
        } else {
            return "Your nickname must have at least 3 characters and can only have alphabetical letters"
        }
    }
    
    var portalIdPrompt: String {
        if isPortalIdValid(portalId) {
            return ""
        } else {
            return "Make sure your portal ID format is correct"
        }
    }
    
    var passwordPrompt: String {
        if isPasswordValid(password) {
            return ""
        } else {
            return "Password doesn't fit required format"
        }
    }
    
    func signUpUser() async {
        defer {loading = false}
        loading = true
        shouldPopView = false
        let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: (String(describing: self)))
        if !signUpFieldsValid {
            signUpErrorToast.title = "Unknown Error"
            signUpErrorToast.subtitle = "Try again"
            signUpErrorToast.show = true
            return
        }
        
        var request = Init_UserSignInRequest()
        request.userID = portalId
        request.password = password
        let response: Init_UserSignInResponse
        do {
            let unaryCall = GRPCServiceManager.shared.initClient.getSISTicket(request)
            let statusCode = try await unaryCall.status.get()
            response = try await unaryCall.response.get()
            print("received results, with status \(statusCode)")
        } catch {
            logger.info("Failed to sign in, setting error message")
            signUpErrorToast.title = "Invalid Credentials"
            signUpErrorToast.subtitle = "Try again"
            signUpErrorToast.show = true
            return
        }
//        let (portalSignIn, portalResponse) = await self.signInToPortal(portalId: portalId, password: password)
        print("received response")
        
        if !response.canLogInToSis || !response.hasTicketURL {
            logger.info("Failed to sign in, setting error message")
            signUpErrorToast.title = "Invalid Credentials"
            signUpErrorToast.subtitle = "Try again"
            signUpErrorToast.show = true
            return
        }
        logger.info("verified can login to portal locally")
        do {
            logger.info("starting supabase signup")
            let user = try await UserManager.shared.supabase.auth.signUp(
                email: "\(portalId)@connect.hku.hk",
                password: password,
                data: [
                    "portal_id": .string(portalId),
                    "nickname": .string(nickname)
                ])
            logger.info("finished supabase signup")
            if user.session != nil {
                logger.critical("Unkown error, user session SHOULD be nil to confirm email")
            }
            if let identities = user.user.identities {
                if identities.isEmpty {
                    logger.info("User has already signed up")
                    shouldPopView = true
                    return
                }
            }
            print(user)
            logger.info("user session empty. great! moving to confirm email")
            showVerifyEmailView = true
        } catch {
            logger.error("\(error.localizedDescription)")
            signUpErrorToast.title = error.localizedDescription
            signUpErrorToast.subtitle = nil
            signUpErrorToast.show = true
        }
    }
}
