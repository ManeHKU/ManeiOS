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

@Observable final class PortalScraper {
    static let shared = PortalScraper()
    private var AF: Session
    private var parser: Parser
    private var isLoggingIn = false
    private var isLocalAuthenticated = false
    var isSignedIn: Bool {
        return isLoggingIn ? false : isLocalAuthenticated
    }
    
    init() {
        self.AF = createNewSession()
        self.parser = Parser()
    }
    
    func resetSession() {
        AF = createNewSession()
    }
    
    @available(*, deprecated, message: "Use gRPC method of getting ticket url to login instead")
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
            let location = response.response?.value(forHTTPHeaderField: "Location")
            if statusCode == 302 && location != nil && location!.contains("z_signon.jsp"){
                logger.info("\(body.username) signed in")
                return (true, response)
            } else if statusCode != 200 {
                logger.error("recevied unknown status code of \(statusCode ?? 0)")
                return (false, response: nil)
            }
            // Old way of logging in
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
    
    func accessTicket(ticketURL: String, cookies: [Init_Cookie]) async -> (gotTicket: Bool,  response: AFDataResponse<Data>?) {
        let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "accessTicket")
        
        self.resetSession()
        if !cookies.isEmpty {
            CookieHandler.shared.setCookies(with: cookies)
        }
        let (_, result) = await getTicket(using: AF, ticketUrl: ticketURL)
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
    }
    
    func accessTicket(ticketURL: String) async -> (gotTicket: Bool,  response: AFDataResponse<Data>?) {
        let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "accessTicket")
        
        let (_, result) = await getTicket(using: AF, ticketUrl: ticketURL)
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
    }
    
    @available(*, deprecated, renamed: "accessTicket", message: "Use the new access ticket function")
    func accessTicket(signInResponse: AFDataResponse<Data>) async -> (gotTicket: Bool,  response: AFDataResponse<Data>?) {
        let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "accessTicket")
        let linkHref: String
        
        logger.info("Extracting location header first")
        if let location = signInResponse.response?.value(forHTTPHeaderField: "Location"), location.contains("z_signon.jsp") {
            logger.info("Found url in location header")
            linkHref = location
        } else {
            logger.info("Extracting html to get ticket url")
            do {
                if signInResponse.value == nil {
                    logger.info("cannot find html")
                    return (false, nil)
                }
                guard let html = String(data: signInResponse.value!, encoding: .utf8) else {
                    return (false, nil)
                }
                let doc = try SwiftSoup.parse(html)
                let link = try doc.select("a").first()!
                linkHref = try link.attr("href")
            } catch {
                logger.error("error when getting ticket: \(error, privacy: .private)")
                return (false, response: nil)
            }
        }
        
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
    
    func fastSISLogin(portalId: String, relogin: Bool = false) async -> Bool{
        let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "fastLogin")
        isLoggingIn = true
        CookieHandler.shared.restoreCookies()
        let (_, sisLoginResult) = await getFastLogin(using: AF, portalId: portalId)
        var ticketURL: String
        func failureAction() async -> Bool {
            if relogin {
                return await reloginToSIS()
            }
            return false
        }
        switch sisLoginResult {
        case.success(let location):
            if location.contains("z_signon.jsp") {
                logger.info("Recevied ticketurl")
                ticketURL = location
            } else if location.contains("cas/aad")  {
                logger.info("Need to send POST request again")
                let (_, aadResult) = await postAADLogin(using: AF, portalId: portalId)
                switch aadResult {
                case .success(let location):
                    ticketURL = location
                case .failure(let error):
                    logger.error("\(error.localizedDescription)")
                    return await failureAction()
                }
            } else {
                return await failureAction()
            }
        case .failure(let error):
            logger.error("\(error.localizedDescription)")
            return await failureAction()
        }
        
        let (ticketAccessed, ticketResponse) = await self.accessTicket(ticketURL: ticketURL)
        if !ticketAccessed || ticketResponse == nil {
            print("failed to access ticket")
            return false
        }
        
        let (sisLoggedIn, _) = await self.sisLogin(ticketResponse: ticketResponse!)
        if !sisLoggedIn {
            print("cannot access home page")
            return false
        }
        print("wohoooo fast logged in happy!!!!!")
        isLoggingIn = false
        isLocalAuthenticated = true
        return true
    }
    
    func signInSIS(portalId: String, password: String) async -> Bool {
        defer {
            print("ending sign in to sis....")
        }
        isLoggingIn = true
        var request = Init_UserSignInRequest()
        request.userID = portalId
        request.password = password
        let response: Init_UserSignInResponse
        do {
            let unaryCall = GRPCServiceManager.shared.initClient.getSISTicket(request)
            let statusCode = try await unaryCall.status.get()
            response = try await unaryCall.response.get()
            print("received results, with status \(statusCode)")
            
        } catch {
            print(error.localizedDescription)
            return false
        }
        //        let (portalSignIn, portalResponse) = await self.signInToPortal(portalId: portalId, password: password)
        print("received response from init service")
        if !response.hasTicketURL {
            print("failed to get ticket url")
            return false
        }
        
        let (ticketAccessed, ticketResponse) = await self.accessTicket(ticketURL: response.ticketURL, cookies: response.cookies)
        if !ticketAccessed || ticketResponse == nil {
            print("failed to access ticket")
            return false
        }
        
        let (sisLoggedIn, _) = await self.sisLogin(ticketResponse: ticketResponse!)
        if !sisLoggedIn {
            print("cannot access home page")
            return false
        }
        print("wohoooo logged in happy!!!!!")
        isLoggingIn = false
        isLocalAuthenticated = true
        return true
    }
    
    func reloginToSIS() async -> Bool {
        self.resetSession()
        guard let portalId = KeychainManager.shared.secureGet(key: .PortalId),
              let password = KeychainManager.shared.secureGet(key: .PortalPassword) else {
            print("portal id or password doesn't exist. whoops")
            return false
        }
        return await self.signInSIS(portalId: portalId, password: password)
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
    
    func getTranscript() async -> Transcript? {
        defer {
            print("ending get transcript....")
        }
        print("starting to get transcript")
        let (_, infoResponse) = await getSISPage(url: .transcript, using: AF)
        switch infoResponse{
        case .success(let response):
            guard let html = String(data: response.value!, encoding: .utf8) else {
                return nil
            }
            print("success on getting transcript html")
            return parser.parseTranscript(html: html)
        case .failure(PortalSignInError.expiredSession):
            print("Session expired. re-login needed")
            //            if await reloginToSIS() {
            //                let (_, infoResponse) = await getSISPage(url: .transcript, using: AF)
            //                if infoResponse.self.
            //            }
        case .failure(let error):
            print(error)
        }
        return nil
    }
    
    func getCourseEnrollmentStatus() async -> SemesterDictArray<CourseInEnrollmentStatus>?{
        defer {
            print("ending getCourseEnrollmentStatuses....")
        }
        print("starting to getCourseEnrollmentStatuses")
        let (_, infoResponse) = await getSISPage(url: .enrollmentStatus, using: AF)
        switch infoResponse{
        case .success(let response):
            guard let html = String(data: response.value!, encoding: .utf8) else {
                return nil
            }
            print("success on getting transcript html")
            return parser.parseEnrollmentStatus(html: html)
        case .failure(PortalSignInError.expiredSession):
            print("Session expired. re-login needed")
            //            if await reloginToSIS() {
            //                let (_, infoResponse) = await getSISPage(url: .transcript, using: AF)
            //                if infoResponse.self.
            //            }
        case .failure(let error):
            print(error)
        }
        return nil
    }
    
    func getEventList() async -> TimetableEvents {
        defer {
            print("ending getEventList....")
        }
        print("starting to getEventList")
        if !isSignedIn {
            print("Not signed in locally, cannot start getting event list")
            return []
        }
        let (_, signInResult) = await signinToEmailCalendar(using: AF)
        let token: String
        switch signInResult {
        case .success(let receivedToken):
            print("received token: \(receivedToken)")
            token = receivedToken
        case .failure(let calendarError):
            print("error logging into event: \(calendarError.localizedDescription), returning nil")
            return []
        }
        let (_, postResult) = await postCalendarEventList(using: AF, token: token)
        print("received post eventList result, eventList is nil: \(postResult == nil)")
        
        // Get the date which is this week's monday
        let cal = Calendar.current
        var comps = cal.dateComponents([.weekOfYear, .yearForWeekOfYear], from: Date.now)
        comps.weekday = 2 // Monday
        let mondayInWeek = cal.date(from: comps)!
        
        if let response = postResult, !response.eventList.isEmpty {
            print("received message: \(response.massage)")
            return response.eventList.filter { event in
                ((event.typeDesc == .personalWorkEvents && (event.categoryDesc == .lectureTimetable || event.categoryDesc == .tutorialTimetable)) || (event.typeDesc == .universityWideEvents && event.categoryDesc == .universityHoliday)) && event.eventStartDate > mondayInWeek
            }
        }
        return []
    }
}
