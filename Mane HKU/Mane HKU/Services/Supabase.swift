//
//  Supabase.swift
//  Mane HKU
//
//  Created by Yau Chin Pang on 8/1/2024.
//

import Foundation
import Supabase
import os

let key = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imh4cHRyZGxmdXR2YnNuZ2hnbHBwIiwicm9sZSI6ImFub24iLCJpYXQiOjE2OTYyNjM1NDcsImV4cCI6MjAxMTgzOTU0N30.lJyolDw6LaK1G2jeXDEgnNb9E9ZCzS2gd6EkcBPigHA"
let supabase = SupabaseClient(supabaseURL: URL(string: "https://hxptrdlfutvbsnghglpp.supabase.co")!, supabaseKey: key)

extension SupabaseClient {
    //    var isSignedIn: Bool {
    //        get async {
    //            let user = try await supabase.auth.user()
    //
    //            return user != nil
    //        }
    //    }
    
    func storeJwtInKeychain() async {
        let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: (String(describing: self)))
        logger.info("saving jwt, started storeJWTinKC")
        let keychain = KeychainManager.shared
        do {
            let jwtToken = try await supabase.auth.session.accessToken
            if keychain.saveStringSecurely(key: .SupabaseJWT, value: jwtToken){
                logger.warning("failed to save jwt in kc, quitting")
                return
            }
            logger.info("saved jwt token")
        } catch {
            logger.critical("failed to save jwt securely")
        }
    }
    
    func getAndStoreJWTFromKeychain() async -> Supabase.User? {
        let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: (String(describing: self)))
        logger.info("retrieve jwt from KC")
        let keychain = KeychainManager.shared
        do {
            let jwt = keychain.getSecuredString(key: .SupabaseJWT)
            let user = try await supabase.auth.user(jwt: jwt)
            return user
        } catch {
            logger.warning("failed to get jwt from KC, re-login is needed.")
        }
        return nil
    }
}
