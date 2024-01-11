//
//  KeychainManager.swift
//  Mane HKU
//
//  Created by Yau Chin Pang on 8/1/2024.
//

import Foundation
import KeychainAccess
import os

class KeychainManager {
    static let shared: Keychain = {
        let bundleId = Bundle.main.bundleIdentifier ?? "dev.yaucp.Mane-HKU"
        let instance = Keychain(service: bundleId)
        
        return instance
    }()
}

extension Keychain {
    func saveStringSecurely(key: KeychainKeys, value: String) -> Bool {
        let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: (String(describing: self)))
        logger.info("Saving data for key \(key.rawValue)")
        let keychain = KeychainManager.shared
        do {
            try keychain.set(value, key: key.rawValue)
            logger.info("Saved keychain")
            return true
        } catch {
            logger.error("\(error.localizedDescription)")
            return false
        }
    }
    
    func getSecuredString(key: KeychainKeys) -> String? {
        let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: (String(describing: self)))
        logger.info("Getting data for key \(key.rawValue)")
        let keychain = KeychainManager.shared
        do {
            let data = try keychain.getString(key.rawValue)
            logger.info("Recevied string")
            return data
        } catch {
            print(error)
            return nil
        }
    }
}

enum KeychainKeys: String {
    case SupabaseJWT = "supabase-jwt"
    case PortalId = "portal-id"
    case PortalPassword = "portal-password"
}
