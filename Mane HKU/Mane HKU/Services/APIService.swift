//
//  APIService.swift
//  Mane HKU
//
//  Created by Yau Chin Pang on 9/1/2024.
//

import Foundation
import Alamofire
import os

protocol ScraperResponse {
    var client: Session? {get}
    var response: HTTPURLResponse? {get}
}

enum PortalURLs: String {
    case login = "https://hkuportal.hku.hk/cas/servlet/edu.yale.its.tp.cas.servlet.Login"
    case fastLogin = "https://hkuportal.hku.hk/cas/login?service=HKUPORTAL"
    case aadLogin = "https://hkuportal.hku.hk/cas/aad"
    case retry = "https://hkuportal.hku.hk/retry.html"
    case logout = "https://hkuportal.hku.hk/cas/logout/l.html"
    case info = "https://sis-main.hku.hk/psc/sisprod/EMPLOYEE/PSFT_CS/c/Z_SS_MENU.Z_MR_ADDRESS_C1.GBL?FolderPath=PORTAL_ROOT_OBJECT.Z_SIS_MENU.Z_STDNT_SELF_SERVICES.Z_MR_ADDRESS_C1_GBL&IsFolder=false&IgnoreParamTempl=FolderPath,IsFolder&PortalActualURL=https://sis-main.hku.hk/psc/sisprod/EMPLOYEE/PSFT_CS/c/Z_SS_MENU.Z_MR_ADDRESS_C1.GBL&PortalContentURL=https://sis-main.hku.hk/psc/sisprod/EMPLOYEE/PSFT_CS/c/Z_SS_MENU.Z_MR_ADDRESS_C1.GBL&PortalContentProvider=PSFT_CS&PortalCRefLabel=View & Change Personal Info&PortalRegistryName=EMPLOYEE&PortalServletURI=https://sis-eportal.hku.hk/psp/ptlprod/&PortalURI=https://sis-eportal.hku.hk/psc/ptlprod/&PortalHostNode=EMPL&NoCrumbs=yes&PortalKeyStruct=yes"
    case transcript = "https://sis-main.hku.hk/psc/sisprod/EMPLOYEE/PSFT_CS/c/Z_SS_MENU.Z_TSRPT_WEB_STDT.GBL?FolderPath=PORTAL_ROOT_OBJECT.Z_SIS_MENU.Z_ACADEMIC_RECORDS.Z_TSRPT_WEB_STDT_GBL&IsFolder=false&IgnoreParamTempl=FolderPath,IsFolder&PortalActualURL=https://sis-main.hku.hk/psc/sisprod/EMPLOYEE/PSFT_CS/c/Z_SS_MENU.Z_TSRPT_WEB_STDT.GBL&PortalContentURL=https://sis-main.hku.hk/psc/sisprod/EMPLOYEE/PSFT_CS/c/Z_SS_MENU.Z_TSRPT_WEB_STDT.GBL&PortalContentProvider=PSFT_CS&PortalCRefLabel=Transcript (Student Copy)&PortalRegistryName=EMPLOYEE&PortalServletURI=https://sis-eportal.hku.hk/psp/ptlprod/&PortalURI=https://sis-eportal.hku.hk/psc/ptlprod/&PortalHostNode=EMPL&NoCrumbs=yes&PortalKeyStruct=yes"
    case enrollmentStatus = "https://sis-main.hku.hk/psc/sisprod/EMPLOYEE/PSFT_CS/c/SA_LEARNER_SERVICES.SSS_STUDENT_CENTER.GBL?pslnkid=Z_ENROLLMENT_STATUS_LNK&FolderPath=PORTAL_ROOT_OBJECT.Z_SIS_MENU.Z_ENROLLMENT.Z_ENROLLMENT_STATUS_LNK&IsFolder=false&IgnoreParamTempl=FolderPath,IsFolder&PortalActualURL=https://sis-main.hku.hk/psc/sisprod/EMPLOYEE/PSFT_CS/c/SA_LEARNER_SERVICES.SSS_STUDENT_CENTER.GBL?pslnkid=Z_ENROLLMENT_STATUS_LNK&PortalContentURL=https://sis-main.hku.hk/psc/sisprod/EMPLOYEE/PSFT_CS/c/SA_LEARNER_SERVICES.SSS_STUDENT_CENTER.GBL?pslnkid=Z_ENROLLMENT_STATUS_LNK&PortalContentProvider=PSFT_CS&PortalCRefLabel=Enrollment Status&PortalRegistryName=EMPLOYEE&PortalServletURI=https://sis-eportal.hku.hk/psp/ptlprod/&PortalURI=https://sis-eportal.hku.hk/psc/ptlprod/&PortalHostNode=EMPL&NoCrumbs=yes&PortalKeyStruct=yes"
}

let doNotFollowRedirector = Redirector(behavior: .doNotFollow)

func createOrGetSession(check session: Session?) -> Session {
    if let unwrapped = session  {
        return unwrapped
    }
    return createNewSession()
}

func createNewSession() -> Session {
    let configuration = URLSessionConfiguration.af.default
    configuration.httpCookieAcceptPolicy = .always
    configuration.httpCookieStorage = HTTPCookieStorage.shared
    configuration.httpAdditionalHeaders?.updateValue("Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:120.0) Gecko/20100101 Firefox/120.0", forKey: "User-Agent")
    let newSession = Session(configuration: configuration)
    return newSession
}

@available(*, deprecated, renamed: "fastLogin", message: "Do not use this for login again")
func postPortalSignIn(using session: Session,_ body: PortalLoginBody) async -> (client: Session, result: Result<AFDataResponse<Data>, Error>) {
    let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "signInToPortal")
    return await withCheckedContinuation { continuation in
        session
            .request(PortalURLs.login.rawValue, method: .post, parameters: body)
            .redirect(using: doNotFollowRedirector)
            .validate()
            .responseData { AFResponse in
                let urlResponse = AFResponse.response
                switch AFResponse.result {
                case .success:
                    logger.info("Recevied good status code")
                    continuation.resume(returning: (session, Result.success(AFResponse)))
                    
                case .failure(let error):
                    logger.error("Failed to login (with \(urlResponse?.statusCode ?? 0) code, error: \(error.localizedDescription)")
                    if urlResponse?.statusCode == 302 {
                        if let location = urlResponse?.value(forHTTPHeaderField: "Location"){
                            if location == PortalURLs.retry.rawValue {
                                continuation.resume(returning: (session, Result.failure(PortalSignInError.wrongCredentials)))
                                return
                            } else if location.contains("z_signon.jsp") {
                                logger.info("Recevied 302 but with correct redirect header")
                                continuation.resume(returning: (session, Result.success(AFResponse)))
                                return
                            }
                        }
                    }
                    continuation.resume(returning:  (session, Result.failure(PortalSignInError.unkown)))
                }
            }
    }
}

func getFastLogin(using session: Session, portalId: String) async -> (client: Session, result: Result<String, Error>){
    let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "fastLogin")
    return await withCheckedContinuation { continuation in
        session
            .request(PortalURLs.fastLogin.rawValue, method: .get)
//            .redirect(using: doNotFollowRedirector)
            .responseData { AFResponse in
                let urlResponse = AFResponse.response
                switch AFResponse.result {
                case .success:
                    let finalURL = AFResponse.response?.url?.absoluteString ?? "unknown"
                    logger.debug("url received:  \(finalURL)")
                    if finalURL.contains("z_signon.jsp") && finalURL.contains("ticket") {
                        logger.info("URL: \(finalURL)")
                        logger.info("Received final url for ticket in 200 code")
                        continuation.resume(returning: (session, Result.success(finalURL)))
                        return
                    }
                    logger.error("Should not receive 200 status code")
                    continuation.resume(returning:  (session, Result.failure(PortalSignInError.unkown)))
                    return
                case .failure(let error):
                    logger.info("Receivd non-200 code in fast login (with \(urlResponse?.statusCode ?? 0) code), error: \(error.localizedDescription)")
                    if urlResponse?.statusCode == 302 {
                        if let location = urlResponse?.value(forHTTPHeaderField: "Location"){
                            logger.info("Received 302 with location: \(location)")
                            continuation.resume(returning: (session, Result.success(location)))
                            return
                        }
                    }
                    continuation.resume(returning:  (session, Result.failure(PortalSignInError.unkown)))
                }
            }
    }
}

func postAADLogin(using session: Session, portalId: String) async -> (client: Session, result: Result<String, Error>){
    let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "postAADLogin")
    let body = [
        "email": "\(portalId)@connect.hku.hk"
    ]
    return await withCheckedContinuation { continuation in
        session
            .request(PortalURLs.aadLogin.rawValue, method: .post, parameters: body)
            .redirect(using: doNotFollowRedirector)
            .responseData { AFResponse in
                let urlResponse = AFResponse.response
                switch AFResponse.result {
                case .success:
                    logger.error("Should not receive 200 status code")
                    continuation.resume(returning:  (session, Result.failure(PortalSignInError.unkown)))
                    
                case .failure(let error):
                    logger.info("AAD: Receivd non-200 code in fast login (with \(urlResponse?.statusCode ?? 0) code), error: \(error.localizedDescription)")
                    if urlResponse?.statusCode == 302 {
                        if let location = urlResponse?.value(forHTTPHeaderField: "Location"){
                            logger.info("AAD: Received location: \(location)")
                            if location.contains("z_signon.jsp") {
                                logger.info("AAD: Recevied 302 but with correct redirect header")
                                continuation.resume(returning: (session, Result.success(location)))
                                return
                            } else {
                                logger.info("Cannot receive tickets, need to relogin")
                                continuation.resume(returning:  (session, Result.failure(PortalSignInError.reloginNeeded)))
                                return
                            }
                        }
                    }
                    continuation.resume(returning:  (session, Result.failure(PortalSignInError.unkown)))
                    return
                }
            }
    }
}

func getTicket(using session: Session,ticketUrl: String) async -> (client: Session, result: Result<AFDataResponse<Data>, Error>) {
    let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "getTicket")
    return await withCheckedContinuation { continuation in
        session
            .request(ticketUrl, method: .get)
            .redirect(using: doNotFollowRedirector)
            .validate()
            .responseData { AFResponse in
                let urlResponse = AFResponse.response
                switch AFResponse.result {
                case .success:
                    logger.info("Recevied good status code + received ticket")
                    continuation.resume(returning: (session, Result.success(AFResponse)))
                    
                case .failure(let error):
                    logger.error("Failed to get ticket (with \(urlResponse?.statusCode ?? 0) code, error: \(error.localizedDescription)")
                    continuation.resume(returning: (session, Result.failure(error)))
                }
            }
    }
}

func postSISLogin(using session: Session,_ body: [String:String], url: String) async -> (Session, Result<AFDataResponse<Data>, Error>) {
    let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "postSISLogin")
    return await withCheckedContinuation { continuation in
        session
            .request(url, method: .post, parameters: body)
        //            .redirect(using: doNotFollowRedirector) redirect is allowed
            .validate()
            .responseData { AFResponse in
                let urlResponse = AFResponse.response
                switch AFResponse.result {
                case .success:
                    logger.info("Recevied good status code for logging into SIS")
                    
                    guard let html = String(data: AFResponse.value!, encoding: .utf8) else {
                        continuation.resume(returning:  (session, Result.failure(PortalSignInError.unkown)))
                        return
                    }
                    if html.contains(PortalURLs.logout.rawValue) {
                        continuation.resume(returning:  (session, Result.failure(PortalSignInError.logoutRequested)))
                        return
                    }
                    continuation.resume(returning: (session, Result.success(AFResponse)))
                    
                case .failure(let error):
                    logger.error("Failed to login to SIS (with \(urlResponse?.statusCode ?? 0) code, error: \(error.localizedDescription)")
                    continuation.resume(returning:  (session, Result.failure(error)))
                }
            }
    }
}

func getSISPage(url: PortalURLs, using session: Session)  async -> (client: Session, result: Result<AFDataResponse<Data>, Error>) {
    let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "getSISPage")
    logger.info("getting url for \(url.rawValue)")
    return await withCheckedContinuation { continuation in
        session
            .request(url.rawValue, method: .get)
            .validate()
            .responseData { AFResponse in
                let urlResponse = AFResponse.response
                switch AFResponse.result {
                case .success:
                    if !validateNotSignedOut(response: AFResponse) {
                        logger.info("Session failed. retried is needed")
                        continuation.resume(returning: (session, Result.failure(PortalSignInError.expiredSession)))
                        return
                    }
                    logger.info("Recevied good status code + received user info")
                    continuation.resume(returning: (session, Result.success(AFResponse)))
                    
                case .failure(let error):
                    logger.error("Failed to get ticket (with \(urlResponse?.statusCode ?? 0) code, error: \(error.localizedDescription)")
                    continuation.resume(returning: (session, Result.failure(error)))
                }
            }
    }
}

func validateNotSignedOut(response: AFDataResponse<Data>) -> Bool {
    guard let html = String(data: response.value!, encoding: .utf8) else {
        return false
    }
    if html.contains("Please login with your HKU Portal UID") {
        return false
    }
    return true
}
