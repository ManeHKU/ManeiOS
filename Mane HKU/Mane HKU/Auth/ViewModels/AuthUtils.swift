//
//  AuthUtils.swift
//  Mane HKU
//
//  Created by Yau Chin Pang on 20/1/2024.
//

import Foundation

func isNicknameValid(_ nickname: String) -> Bool {
    nickname.count > 2 && nickname.isAlphabetical
}

func isPortalIdValid(_ portalId: String) -> Bool {
    (4...8).contains(portalId.count) && portalId.isAlphanumeric
}

func isPasswordValid(_ password: String) -> Bool {
    let passwordRegex = /^(?=.*[a-zA-Z])(?=.*\d)[a-zA-Z\d]{10,18}$/
    return password.wholeMatch(of: passwordRegex) != nil
}
