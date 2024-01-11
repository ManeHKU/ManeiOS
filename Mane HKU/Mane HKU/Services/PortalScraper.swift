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

class PortalScraper {
    private var AF: Session
    
    init() {
        self.AF = createNewSession()
    }
    
    private func resetSession() {
        AF = createNewSession()
    }
    
    func signInToPortal(portalId: String, password: String) async -> (successfulSignIn: Bool, response: AFDataResponse<Data>?) {
        let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "verifyPortalSignIn")

        if portalId.isEmpty || password.isEmpty  {
            logger.error("Missing portal id or password")
            return (successfulSignIn: false, response: nil)
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
        do{
            let (_, response) =  try await postPortalSignIn(session: AF, body)
            let statusCode = response.response?.statusCode
            if statusCode != 200 {
                logger.info("recevied unknown status code of \(statusCode ?? 0)")
                return (false, response: nil)
            }
            logger.info("\(body.username) signed in")
            
            logger.info("Searching for the phrase confirming successful login")
            guard let html = String(data: response.value!, encoding: .utf8) else {
                return (false, response)
            }
            print(html)
            return (html.contains("Login successful"), response)
        } catch PortalSignInError.wrongCredentials {
            logger.info("\(body.username) wrong credentials")
            return (false, response: nil)
        } catch {
            logger.error("\(error.localizedDescription)")
            return (false, response: nil)
        }
        
        
    }

}

let portalScraper = PortalScraper()
