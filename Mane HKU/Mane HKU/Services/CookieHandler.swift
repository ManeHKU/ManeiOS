//
//  CookieHandler.swift
//  Mane HKU
//
//  Created by Yau Chin Pang on 26/2/2024.
//

import Foundation

final class CookieHandler {
    
    static let shared: CookieHandler = CookieHandler()
    
    let defaults = UserDefaults.standard
    let cookieStorage = HTTPCookieStorage.shared
    
    func getCookie(forURL url: String) -> [HTTPCookie] {
        let computedUrl = URL(string: url)
        let cookies = cookieStorage.cookies(for: computedUrl!) ?? []
        
        return cookies
    }
    
    func getCookies() -> [HTTPCookie] {
        let cookies = cookieStorage.cookies ?? []
        
        return cookies
    }
    
    func backupAllCookies() -> Void {
        var cookieDict = [String : AnyObject]()
        
        for cookie in self.getCookies() {
            cookieDict[cookie.name] = cookie.properties as AnyObject?
        }
        
        defaults.set(cookieDict, forKey: UserDefaults.DefaultKey.cookies.rawValue)
    }
    
    func restoreCookies() {
        if let cookieDictionary = defaults.dictionary(forKey: UserDefaults.DefaultKey.cookies.rawValue) {
            for (_, cookieProperties) in cookieDictionary {
                if let cookie = HTTPCookie(properties: cookieProperties as! [HTTPCookiePropertyKey : Any] ) {
                    cookieStorage.setCookie(cookie)
                }
            }
        }
    }
    
    func setCookies(with remoteCookies: [Init_Cookie]) {
        for remoteCookie in remoteCookies {
            if let cookie = HTTPCookie(properties: remoteCookie.dictionary) {
                cookieStorage.setCookie(cookie)
                print("success set cookie \(cookie.name)")
            } else {
                print("failed to init \(remoteCookie.name)")
            }
        }
    }
}
