//
//  PortalScraper.swift
//  Mane HKU
//
//  Created by Yau Chin Pang on 9/1/2024.
//

import Foundation
import Alamofire
import os
import SwiftSoup

final class PortalScraper {
    static let shared = PortalScraper()
    private var AF: Session
    private var parser: Parser
    
    init() {
        self.AF = createNewSession()
        self.parser = Parser()
    }
    
    func resetSession() {
        AF = createNewSession()
    }
    
    
    func signInToPortal(portalId: String, password: String) async -> (successSignIn: Bool, response: AFDataResponse<Data>?) {
        let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "verifyPortalSignIn")
        
        if portalId.isEmpty || password.isEmpty  {
            logger.error("Missing portal id or password")
            return (false, nil)
        }
        
        logger.info("Generating keyId")
        let now = Date.now
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "M"
        let monthZeroBased = (Int(dateFormatter.string(from: now)) ?? 1) - 1
        dateFormatter.dateFormat = "yyyy\(monthZeroBased)dHms"
        let keyId = dateFormatter.string(from: now)
        logger.info("KeyId: \(keyId), building body")
        
        let body = PortalLoginBody(keyId: keyId, username: portalId, password: password)
        logger.info("Verifying \(body.username)")
        let (_, result) = await postPortalSignIn(using: AF, body)
        switch result {
        case.success(let response):
            let statusCode = response.response?.statusCode
            if statusCode != 200 {
                logger.error("recevied unknown status code of \(statusCode ?? 0)")
                return (false, response: nil)
            }
            logger.info("\(body.username) signed in")
            
            logger.info("Searching for the phrase confirming successful login")
            guard let html = String(data: response.value!, encoding: .utf8) else {
                return (false, response)
            }
            print(html)
            return (html.contains("Login successful"), response)
        case .failure(PortalSignInError.wrongCredentials):
            logger.info("\(body.username) wrong credentials")
            return (false, response: nil)
        case .failure(let error):
            logger.error("\(error.localizedDescription)")
            return (false, response: nil)
        }
    }
    
    func accessTicket(signInResponse: AFDataResponse<Data>) async -> (gotTicket: Bool,  response: AFDataResponse<Data>?) {
        let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "verifyPortalSignIn")
        
        logger.info("Extracting html to get ticket url")
        if signInResponse.value == nil {
            logger.info("cannot find html")
            return (false, nil)
        }
        guard let html = String(data: signInResponse.value!, encoding: .utf8) else {
            return (false, nil)
        }
        
        do {
            let doc = try SwiftSoup.parse(html)
            let link = try doc.select("a").first()!
            let linkHref = try link.attr("href")
            
            let (_, result) = await getTicket(using: AF, ticketUrl: linkHref)
            switch result {
            case.success(let response):
                print("received good response, checking keywords")
                guard let html = String(data: response.value!, encoding: .utf8) else {
                    return (false, response)
                }
                print(html)
                return (html.contains("HKU CAS Signon Page"), response)
            case .failure(let error):
                logger.error("\(error.localizedDescription)")
                return (false, response: nil)
            }
            
        } catch {
            logger.error("error when getting ticket: \(error, privacy: .private)")
            return (false, response: nil)
        }
        
    }
    
    func sisLogin(ticketResponse: AFDataResponse<Data>) async -> (Bool, AFDataResponse<Data>?)  {
        let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "sisLogin")
        
        logger.info("Extracting html to get the input fields")
        if ticketResponse.value == nil {
            logger.info("cannot find html")
            return (false, nil)
        }
        
        guard let html = String(data: ticketResponse.value!, encoding: .utf8) else {
            return (false, nil)
        }
        
        do {
            let doc = try SwiftSoup.parse(html)
            let actionUrl = try doc.select("form").first()!.attr("action")
            let inputElements = try doc.select("input")
            var body: [String: String] = [:]
            for input in inputElements.array() {
                let name = try input.attr("name")
                let value = try input.attr("value")
                body[name] = value
            }
            
            let (newSession, sisLoginResult) = await postSISLogin(using: AF, body, url: actionUrl)
            
            switch sisLoginResult {
            case.success(let response):
                print("received good response, checking keywords to see if in home page or not")
                guard let html = String(data: response.value!, encoding: .utf8) else {
                    return (false, response)
                }
                print(html)
                return (html.contains("Last Login:"), response)
            case .failure(let error):
                logger.error("\(error.localizedDescription)")
                return (false, response: nil)
            }
        } catch {
            logger.error("error when logging into SIS: \(error, privacy: .private)")
            return (false, response: nil)
        }
    }
    
    func signInSIS(portalId: String, password: String) async -> Bool {
        defer {
            print("ending sign in to sis....")
        }
        let (portalSignIn, portalResponse) = await self.signInToPortal(portalId: portalId, password: password)
        if !portalSignIn || portalResponse == nil {
            print("failed to sign in to portal")
            return false
        }
        print("signed in to portal")
        
        let (ticketAccessed, ticketResponse) = await self.accessTicket(signInResponse: portalResponse!)
        if !ticketAccessed || ticketResponse == nil {
            print("failed to access ticket")
            return false
        }
        
        let (sisLoggedIn, sisResponse) = await self.sisLogin(ticketResponse: ticketResponse!)
        if !sisLoggedIn {
            print("cannot access home page")
            return false
        }
        print("wohoooo logged in happy!!!!!")
        return true
    }
    
    func getUserInfo() async -> UserInfo? {
        defer {
            print("ending get user info....")
        }
        print("starting to get user info")
        let (session, infoResponse) = await getSISPage(url: .info, using: AF)
        switch infoResponse{
        case .success(let response):
            guard let html = String(data: response.value!, encoding: .utf8) else {
                return nil
            }
            print("success on getting user info html")
            return parser.parseInfo(html: html)
        case .failure(PortalSignInError.expiredSession):
            print("Session expired. re-login needed")
        case .failure(let error):
            print(error)
        }
        return nil
    }
}
