//
//  UserManager.swift
//  Mane HKU
//
//  Created by Yau Chin Pang on 17/1/2024.
//

import Foundation
import Supabase
import NIOCore
import SwiftUI

let key = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imh4cHRyZGxmdXR2YnNuZ2hnbHBwIiwicm9sZSI6ImFub24iLCJpYXQiOjE2OTYyNjM1NDcsImV4cCI6MjAxMTgzOTU0N30.lJyolDw6LaK1G2jeXDEgnNb9E9ZCzS2gd6EkcBPigHA"

final actor UserManager {
    static let shared = UserManager()
    var supabase: SupabaseClient
    var session: Session?
    
    public var isAuthenticated: Bool {
        let now = Date.now.timeIntervalSince1970
        if let unwrappedSession = session {
            return unwrappedSession.expiresAt != nil ? now < unwrappedSession.expiresAt! : false
        }
        return false
    }
    
    public var token: String? {
        get async {
            try? await supabase.auth.session.accessToken
        }
    }
    
    private init() {
        supabase = SupabaseClient(supabaseURL: URL(string: "https://hxptrdlfutvbsnghglpp.supabase.co")!, supabaseKey: key)
        Task(priority: .high) {
            await authEventHandler()
        }
    }
    
    func checkLocalTokenValid() async -> Bool{
        let jwtTokens = KeychainManager.shared.secureGet(key: .jwtToken, dataType: JWTToken.self)
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
                print("initialised")
            case .signedIn:
                print("signed in \(String(describing: session?.user))")
                self.session = session
                updateKeychainToken()
                let nickname = self.session?.user.userMetadata["nickname"]?.stringValue ?? ""
                let defaults = UserDefaults.standard
                defaults.set(nickname, forKey: UserDefaults.DefaultKey.nickname.rawValue)
            case .signedOut:
                print("signed out: \(String(describing: session?.user))")
                self.session = nil
                do {
                    try KeychainManager.shared.removeAll()
                    let domain = Bundle.main.bundleIdentifier!
                    UserDefaults.standard.removePersistentDomain(forName: domain)
                    CookieHandler.shared.removeAllCookies()
                } catch let error {
                    print("cannot remove all data: \(error)")
                }
            case .tokenRefreshed:
                print("refreshed token: \(String(describing: session))")
                self.session = session
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
    
    func getEventImage(at path: String) async -> Image? {
        if path.isEmpty {
            return nil
        }
        guard let data = try? await supabase.storage
          .from("event")
          .download(path: path) else {
            return nil
        }
        
        guard let uiImage = UIImage(data: data) else {
            return nil
        }
        
        return Image(uiImage: uiImage)
    }
    
    func addEventImage(from itemID: String, data image: Data, fileType: String) async throws -> String {
        if itemID.isEmpty {
            throw AddImageError.itemIDError
        }
        do {
            let key = "public/images/\(itemID)"
            let _ = try await supabase.storage.from("event").upload(path: key, file: image, options: FileOptions(contentType: fileType, upsert: true))
            return key
        } catch (let error) {
            print("error during upload \(error.localizedDescription)")
            throw AddImageError.failedToUpload(error.localizedDescription)
        }
    }
}

enum AddImageError: Error {
    case itemIDError, failedToUpload(String)
}

enum UserManagerError: Error {
    case notAuthenticated
}
