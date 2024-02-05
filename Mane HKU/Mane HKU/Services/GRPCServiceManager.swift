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
    private let group = PlatformSupport.makeEventLoopGroup(loopCount: 1)
    static let shared = GRPCServiceManager()
    var serviceClient: Service_MainServiceClientProtocol!
    private init() {
        let channel = ClientConnection(configuration: .default(target: ConnectionTarget.hostAndPort("0.tcp.ap.ngrok.io", 18952), eventLoopGroup: group))
        serviceClient = Service_MainServiceNIOClient(channel: channel)
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
