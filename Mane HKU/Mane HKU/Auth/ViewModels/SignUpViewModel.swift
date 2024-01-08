//
//  SignUpViewModel.swift
//  Mane HKU
//
//  Created by Yau Chin Pang on 6/1/2024.
//

import Foundation
import Observation

@Observable class SignUpViewModel {
    var nickname: String = ""
    var portalId: String = ""
    var password: String = ""
    
    var signUpFieldsValid: Bool {
         isNicknameValid() && portalId.count > 3 && isPasswordValid()
    }
    
    var nicknamePrompt: String {
        if isNicknameValid() {
            return ""
        } else {
            return "Your nickname must have at least 3 characters and do not have other special symbols."
        }
    }
    
    var portalIdPrompt: String {
        if isPortalIdValid() {
            return ""
        } else {
            return "Enter your portal UID."
        }
    }
    
    var passwordPrompt: String {
        if isPasswordValid() {
            return ""
        } else {
            return "Enter your portal password."
        }
    }
    
    func isNicknameValid() -> Bool {
        nickname.count > 3 && nickname.isAlphanumeric
    }
    
    func isPortalIdValid() -> Bool {
        (4...8).contains(portalId.count) && portalId.isAlphanumeric
    }
    
    func isPasswordValid() -> Bool {
        let passwordRegex = /^(?=.*[a-zA-Z])(?=.*\d)[a-zA-Z\d]{10,18}$/
        return password.wholeMatch(of: passwordRegex) != nil
    }
}
