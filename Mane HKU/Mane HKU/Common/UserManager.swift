//
//  UserManager.swift
//  Mane HKU
//
//  Created by Yau Chin Pang on 17/1/2024.
//

import Foundation
import Supabase

let key = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imh4cHRyZGxmdXR2YnNuZ2hnbHBwIiwicm9sZSI6ImFub24iLCJpYXQiOjE2OTYyNjM1NDcsImV4cCI6MjAxMTgzOTU0N30.lJyolDw6LaK1G2jeXDEgnNb9E9ZCzS2gd6EkcBPigHA"

@Observable class UserManager: ObservableObject {
    var supabase: SupabaseClient
    var session: Session?
    public var isAuthenticated: Bool {
        let now = Date.now.timeIntervalSince1970
        if let unwrappedSession = session {
            return unwrappedSession.expiresAt != nil ? now < unwrappedSession.expiresAt! : false
        }
        return false
    }
    
    init() {
        supabase = SupabaseClient(supabaseURL: URL(string: "https://hxptrdlfutvbsnghglpp.supabase.co")!, supabaseKey: key)
        
        Task(priority: .high) {
            await authEventHandler()
        }
    }
    
    func checkLocalTokenValid() async -> Bool{
        let jwtTokens = KeychainManager.shared.secureGet(key: .jwtToken, dataType: JWTToken.self)
        print(jwtTokens)
        if let unwrappedTokens = jwtTokens {
            let validLocalToken = Task(priority: .high) { () -> Bool in
                do{
                    try await self.supabase.auth.setSession(accessToken: unwrappedTokens.jwt, refreshToken: unwrappedTokens.refreshToken)
                    print("new session initialised")
                    // Set content to logged in, authed view
                    return true
                } catch {
                    print(error)
                    print("failed to add session")
                }
                return false
            }
            let result = await validLocalToken.result
            do {
                return try result.get()
            } catch {
                print("Unknown error.")
            }
            return false
        }
        // no local saved token
        print("no saved keychain keys locally")
        return false
    }
    
    func authEventHandler() async {
        print("auth event handler started")
        for await (event, session) in await supabase.auth.authStateChanges {
            switch event {
            case .initialSession:
                print("initial token: \(String(describing: session?.user))")
            case .signedIn:
                print("signed in \(String(describing: session?.user))")
                self.session = session
                updateKeychainToken()
            case .signedOut:
                print("signed out: \(String(describing: session?.user))")
                self.session = nil
                do {
                    try KeychainManager.shared.removeAll()
                } catch let error {
                    print("cannot remove all data: \(error)")
                }
            case .tokenRefreshed:
                print("refreshed token: \(String(describing: session))")
                updateKeychainToken()
            default:
                print("uncatched: \(event)")
            }
        }
    }
    
    func updateKeychainToken() {
        guard let accessToken = session?.accessToken , let refreshToken = session?.refreshToken else {
            print("no tokens find, tokens not saved")
            return
        }
        let jwtTokens = JWTToken(jwt: accessToken, refreshToken: refreshToken)
        KeychainManager.shared.secureSave(key: .jwtToken, value: jwtTokens)
        print("updated KC local token")
    }
}
