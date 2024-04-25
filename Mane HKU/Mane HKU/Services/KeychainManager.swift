//
//  KeychainManager.swift
//  Mane HKU
//
//  Created by Yau Chin Pang on 8/1/2024.
//

import Foundation
import KeychainAccess
import os

final class KeychainManager {
    static let shared: Keychain = {
        let bundleId = Bundle.main.bundleIdentifier ?? "dev.yaucp.Mane-HKU"
        let instance = Keychain(service: bundleId)
        
        return instance
    }()
}

extension Keychain {
    @discardableResult func secureSave(key: KeychainKeys, value: String) -> Bool {
        let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: (String(describing: self)))
        logger.info("Saving string for key \(key.rawValue)")
        let keychain = KeychainManager.shared
        do {
            try keychain.set(value, key: key.rawValue)
            logger.info("Saved to keychain")
            return true
        } catch {
            logger.error("\(error.localizedDescription)")
            return false
        }
    }
    
    @discardableResult func secureSave(key: KeychainKeys, value: any Codable) -> Bool {
        let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: (String(describing: self)))
        logger.info("Saving data for key \(key.rawValue)")
        let keychain = KeychainManager.shared
        do {
            let encodedData = try JSONEncoder().encode(value)
//            print("encodedJWT: \(encodedData)")
            try keychain.set(encodedData, key: key.rawValue)
            logger.info("Saved to keychain")
            return true
        } catch {
            logger.error("\(error.localizedDescription)")
            return false
        }
    }
    
    func secureGet(key: KeychainKeys) -> String? {
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
    
    func secureGet<T: Codable>(key: KeychainKeys, dataType: T.Type) -> T? {
        let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: (String(describing: self)))
        logger.info("Getting data for key \(key.rawValue)")
        let keychain = KeychainManager.shared
        do {
            guard let data = try keychain.getData(key.rawValue) else { return nil }
            logger.info("Recevied data")
            let decodedData = try JSONDecoder().decode(dataType, from: data)
//            print("decodedData: \(decodedData)")
            return decodedData
        } catch {
            print(error)
            return nil
        }
    }
}

enum KeychainKeys: String {
    case jwtToken = "supabase-jwt"
    case PortalId = "portal-id"
    case PortalPassword = "portal-password"
}

struct JWTToken: Codable {
    var jwt: String
    var refreshToken: String
}
