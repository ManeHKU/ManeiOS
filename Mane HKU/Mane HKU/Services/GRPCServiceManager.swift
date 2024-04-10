//
//  GRPCServiceManager.swift
//  Mane HKU
//
//  Created by Yau Chin Pang on 28/1/2024.
//

import Foundation
import GRPC
import NIO
import NIOConcurrencyHelpers
import SwiftProtobuf
import os

final class GRPCServiceManager {
    private let group = PlatformSupport.makeEventLoopGroup(loopCount: 1, networkPreference: .best)
    static let shared = GRPCServiceManager()
    var serviceClient: Service_MainServiceClientProtocol!
    var initClient: Init_InitServiceClientProtocol!
    private init() {
        // ConnectionTarget.hostAndPort("mane-service-uknkqgo4rq-df.a.run.app", 8080)
        let channel = ClientConnection(configuration: .default(target: ConnectionTarget.hostAndPort("0.tcp.ap.ngrok.io", 12533) , eventLoopGroup: group))
        serviceClient = Service_MainServiceNIOClient(channel: channel)
        initClient = Init_InitServiceNIOClient(channel: channel)
    }
    
    deinit {
        _ = serviceClient.channel.close()
    }
    
    func getCallOptionsWithToken() async throws -> CallOptions {
        var callOptions = CallOptions()
        guard let token = await UserManager.shared.token else {
            throw UserManagerError.notAuthenticated
        }
        callOptions.customMetadata.add(name: "authorization", value: "Bearer \(token)")
        return callOptions
    }
}

extension GRPCClient {
    func makeUnaryCallWithRetry<Request, Response>(
        _ unaryFunction: @escaping (Request, CallOptions?) -> UnaryCall<Request, Response>,
        _ request: Request,
        callOptions: CallOptions? = nil,
        shouldRetry: @escaping (Error) -> Bool = { _ in true },
        retries: Int = 3
    ) -> EventLoopFuture<Response> {
        let unaryCall = unaryFunction(request, callOptions)
        let eventLoop = unaryCall.eventLoop
        return unaryCall.response
            .flatMapError { error in
                guard retries > 0 else {
                    return eventLoop.makeFailedFuture(error)
                }
                
                guard shouldRetry(error) else {
                    return eventLoop.makeFailedFuture(error)
                }
                
                return self.makeUnaryCallWithRetry(
                    unaryFunction,
                    request,
                    callOptions: callOptions,
                    shouldRetry: shouldRetry,
                    retries: retries - 1
                )
            }
    }
}

extension Init_Cookie {
    var dictionary: [HTTPCookiePropertyKey: Any] {
        return [
            .name: self.name,
            .value: self.value,
            .domain: self.domain,
            .path: self.path,
            .expires: self.expires == -1 ? "" : NSDate(timeIntervalSinceReferenceDate: TimeInterval(self.expires)) as Any,
            .secure: self.secure,
            .init(rawValue: "HttpOnly"): self.httponly,
            .sameSitePolicy: self.sameSite,
            .port: self.sourcePort,
        ]
    }
}
