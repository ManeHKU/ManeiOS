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
    case retry = "https://hkuportal.hku.hk/retry.html"
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
    configuration.httpAdditionalHeaders?.updateValue("Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:120.0) Gecko/20100101 Firefox/120.0", forKey: "User-Agent")
    let newSession = Session(configuration: configuration)
    return newSession
}

func postPortalSignIn(session: Session,_ body: PortalLoginBody) async throws -> (client: Session, response: AFDataResponse<Data>) {
    let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "signInToPortal")
    return try await withCheckedThrowingContinuation { continuation in
        session
            .request(PortalURLs.login.rawValue, method: .post, parameters: body)
            .redirect(using: doNotFollowRedirector)
            .validate()
            .responseData { AFResponse in
                let urlResponse = AFResponse.response
                switch AFResponse.result {
                case .success:
                    logger.info("Recevied good status code")
                    continuation.resume(returning: (client: AF, response: AFResponse))
                    
                case .failure(let error):
                    logger.error("Failed to login (with \(urlResponse?.statusCode ?? 0) code, error: \(error.localizedDescription)")
                    if urlResponse?.statusCode == 302{
                        if let location = urlResponse?.value(forHTTPHeaderField: "Location"){
                            if location == PortalURLs.retry.rawValue {
                                continuation.resume(throwing: PortalSignInError.wrongCredentials)
                                return
                            }
                        }
                    }
                    continuation.resume(throwing: PortalSignInError.unkown)
                }
            }
    }
}

