//
//  PortalAuth.swift
//  Mane HKU
//
//  Created by Yau Chin Pang on 10/1/2024.
//

import Foundation

enum PortalSignInError: Error {
    case wrongCredentials, expiredSession, retryAgain, unkown, logoutRequested, reloginNeeded
}

extension PortalSignInError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .wrongCredentials:
            return NSLocalizedString("Your credentials are wrong. If this error happens again, the server may experiencing unknown issues", comment: "Wrong credentials")
        case .expiredSession:
            return NSLocalizedString("Session expired. Please retry.", comment: "Expired")
        case .retryAgain:
            return NSLocalizedString("Please retry again", comment: "Portal retry")
        default:
            return NSLocalizedString("Unknown Error", comment: "Unknown")
        }
    }
}

struct PortalLoginBody: Encodable {
    let keyId: String
    let username: String
    let password: String
}

struct PortalLoginDetails {
    let portalId: String
    let password: String
}

