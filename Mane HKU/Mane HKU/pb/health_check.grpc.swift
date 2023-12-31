//
// DO NOT EDIT.
// swift-format-ignore-file
//
// Generated by the protocol buffer compiler.
// Source: health_check.proto
//
import GRPC
import NIO
import NIOConcurrencyHelpers
import SwiftProtobuf


/// Usage: instantiate `Grpc_Health_V1_HealthClient`, then call methods of this protocol to make API calls.
public protocol Grpc_Health_V1_HealthClientProtocol: GRPCClient {
  var serviceName: String { get }
  var interceptors: Grpc_Health_V1_HealthClientInterceptorFactoryProtocol? { get }

  func check(
    _ request: Grpc_Health_V1_HealthCheckRequest,
    callOptions: CallOptions?
  ) -> UnaryCall<Grpc_Health_V1_HealthCheckRequest, Grpc_Health_V1_HealthCheckResponse>

  func watch(
    _ request: Grpc_Health_V1_HealthCheckRequest,
    callOptions: CallOptions?,
    handler: @escaping (Grpc_Health_V1_HealthCheckResponse) -> Void
  ) -> ServerStreamingCall<Grpc_Health_V1_HealthCheckRequest, Grpc_Health_V1_HealthCheckResponse>
}

extension Grpc_Health_V1_HealthClientProtocol {
  public var serviceName: String {
    return "grpc.health.v1.Health"
  }

  /// Unary call to Check
  ///
  /// - Parameters:
  ///   - request: Request to send to Check.
  ///   - callOptions: Call options.
  /// - Returns: A `UnaryCall` with futures for the metadata, status and response.
  public func check(
    _ request: Grpc_Health_V1_HealthCheckRequest,
    callOptions: CallOptions? = nil
  ) -> UnaryCall<Grpc_Health_V1_HealthCheckRequest, Grpc_Health_V1_HealthCheckResponse> {
    return self.makeUnaryCall(
      path: Grpc_Health_V1_HealthClientMetadata.Methods.check.path,
      request: request,
      callOptions: callOptions ?? self.defaultCallOptions,
      interceptors: self.interceptors?.makeCheckInterceptors() ?? []
    )
  }

  /// Server streaming call to Watch
  ///
  /// - Parameters:
  ///   - request: Request to send to Watch.
  ///   - callOptions: Call options.
  ///   - handler: A closure called when each response is received from the server.
  /// - Returns: A `ServerStreamingCall` with futures for the metadata and status.
  public func watch(
    _ request: Grpc_Health_V1_HealthCheckRequest,
    callOptions: CallOptions? = nil,
    handler: @escaping (Grpc_Health_V1_HealthCheckResponse) -> Void
  ) -> ServerStreamingCall<Grpc_Health_V1_HealthCheckRequest, Grpc_Health_V1_HealthCheckResponse> {
    return self.makeServerStreamingCall(
      path: Grpc_Health_V1_HealthClientMetadata.Methods.watch.path,
      request: request,
      callOptions: callOptions ?? self.defaultCallOptions,
      interceptors: self.interceptors?.makeWatchInterceptors() ?? [],
      handler: handler
    )
  }
}

@available(*, deprecated)
extension Grpc_Health_V1_HealthClient: @unchecked Sendable {}

@available(*, deprecated, renamed: "Grpc_Health_V1_HealthNIOClient")
public final class Grpc_Health_V1_HealthClient: Grpc_Health_V1_HealthClientProtocol {
  private let lock = Lock()
  private var _defaultCallOptions: CallOptions
  private var _interceptors: Grpc_Health_V1_HealthClientInterceptorFactoryProtocol?
  public let channel: GRPCChannel
  public var defaultCallOptions: CallOptions {
    get { self.lock.withLock { return self._defaultCallOptions } }
    set { self.lock.withLockVoid { self._defaultCallOptions = newValue } }
  }
  public var interceptors: Grpc_Health_V1_HealthClientInterceptorFactoryProtocol? {
    get { self.lock.withLock { return self._interceptors } }
    set { self.lock.withLockVoid { self._interceptors = newValue } }
  }

  /// Creates a client for the grpc.health.v1.Health service.
  ///
  /// - Parameters:
  ///   - channel: `GRPCChannel` to the service host.
  ///   - defaultCallOptions: Options to use for each service call if the user doesn't provide them.
  ///   - interceptors: A factory providing interceptors for each RPC.
  public init(
    channel: GRPCChannel,
    defaultCallOptions: CallOptions = CallOptions(),
    interceptors: Grpc_Health_V1_HealthClientInterceptorFactoryProtocol? = nil
  ) {
    self.channel = channel
    self._defaultCallOptions = defaultCallOptions
    self._interceptors = interceptors
  }
}

public struct Grpc_Health_V1_HealthNIOClient: Grpc_Health_V1_HealthClientProtocol {
  public var channel: GRPCChannel
  public var defaultCallOptions: CallOptions
  public var interceptors: Grpc_Health_V1_HealthClientInterceptorFactoryProtocol?

  /// Creates a client for the grpc.health.v1.Health service.
  ///
  /// - Parameters:
  ///   - channel: `GRPCChannel` to the service host.
  ///   - defaultCallOptions: Options to use for each service call if the user doesn't provide them.
  ///   - interceptors: A factory providing interceptors for each RPC.
  public init(
    channel: GRPCChannel,
    defaultCallOptions: CallOptions = CallOptions(),
    interceptors: Grpc_Health_V1_HealthClientInterceptorFactoryProtocol? = nil
  ) {
    self.channel = channel
    self.defaultCallOptions = defaultCallOptions
    self.interceptors = interceptors
  }
}

@available(macOS 10.15, iOS 13, tvOS 13, watchOS 6, *)
public protocol Grpc_Health_V1_HealthAsyncClientProtocol: GRPCClient {
  static var serviceDescriptor: GRPCServiceDescriptor { get }
  var interceptors: Grpc_Health_V1_HealthClientInterceptorFactoryProtocol? { get }

  func makeCheckCall(
    _ request: Grpc_Health_V1_HealthCheckRequest,
    callOptions: CallOptions?
  ) -> GRPCAsyncUnaryCall<Grpc_Health_V1_HealthCheckRequest, Grpc_Health_V1_HealthCheckResponse>

  func makeWatchCall(
    _ request: Grpc_Health_V1_HealthCheckRequest,
    callOptions: CallOptions?
  ) -> GRPCAsyncServerStreamingCall<Grpc_Health_V1_HealthCheckRequest, Grpc_Health_V1_HealthCheckResponse>
}

@available(macOS 10.15, iOS 13, tvOS 13, watchOS 6, *)
extension Grpc_Health_V1_HealthAsyncClientProtocol {
  public static var serviceDescriptor: GRPCServiceDescriptor {
    return Grpc_Health_V1_HealthClientMetadata.serviceDescriptor
  }

  public var interceptors: Grpc_Health_V1_HealthClientInterceptorFactoryProtocol? {
    return nil
  }

  public func makeCheckCall(
    _ request: Grpc_Health_V1_HealthCheckRequest,
    callOptions: CallOptions? = nil
  ) -> GRPCAsyncUnaryCall<Grpc_Health_V1_HealthCheckRequest, Grpc_Health_V1_HealthCheckResponse> {
    return self.makeAsyncUnaryCall(
      path: Grpc_Health_V1_HealthClientMetadata.Methods.check.path,
      request: request,
      callOptions: callOptions ?? self.defaultCallOptions,
      interceptors: self.interceptors?.makeCheckInterceptors() ?? []
    )
  }

  public func makeWatchCall(
    _ request: Grpc_Health_V1_HealthCheckRequest,
    callOptions: CallOptions? = nil
  ) -> GRPCAsyncServerStreamingCall<Grpc_Health_V1_HealthCheckRequest, Grpc_Health_V1_HealthCheckResponse> {
    return self.makeAsyncServerStreamingCall(
      path: Grpc_Health_V1_HealthClientMetadata.Methods.watch.path,
      request: request,
      callOptions: callOptions ?? self.defaultCallOptions,
      interceptors: self.interceptors?.makeWatchInterceptors() ?? []
    )
  }
}

@available(macOS 10.15, iOS 13, tvOS 13, watchOS 6, *)
extension Grpc_Health_V1_HealthAsyncClientProtocol {
  public func check(
    _ request: Grpc_Health_V1_HealthCheckRequest,
    callOptions: CallOptions? = nil
  ) async throws -> Grpc_Health_V1_HealthCheckResponse {
    return try await self.performAsyncUnaryCall(
      path: Grpc_Health_V1_HealthClientMetadata.Methods.check.path,
      request: request,
      callOptions: callOptions ?? self.defaultCallOptions,
      interceptors: self.interceptors?.makeCheckInterceptors() ?? []
    )
  }

  public func watch(
    _ request: Grpc_Health_V1_HealthCheckRequest,
    callOptions: CallOptions? = nil
  ) -> GRPCAsyncResponseStream<Grpc_Health_V1_HealthCheckResponse> {
    return self.performAsyncServerStreamingCall(
      path: Grpc_Health_V1_HealthClientMetadata.Methods.watch.path,
      request: request,
      callOptions: callOptions ?? self.defaultCallOptions,
      interceptors: self.interceptors?.makeWatchInterceptors() ?? []
    )
  }
}

@available(macOS 10.15, iOS 13, tvOS 13, watchOS 6, *)
public struct Grpc_Health_V1_HealthAsyncClient: Grpc_Health_V1_HealthAsyncClientProtocol {
  public var channel: GRPCChannel
  public var defaultCallOptions: CallOptions
  public var interceptors: Grpc_Health_V1_HealthClientInterceptorFactoryProtocol?

  public init(
    channel: GRPCChannel,
    defaultCallOptions: CallOptions = CallOptions(),
    interceptors: Grpc_Health_V1_HealthClientInterceptorFactoryProtocol? = nil
  ) {
    self.channel = channel
    self.defaultCallOptions = defaultCallOptions
    self.interceptors = interceptors
  }
}

public protocol Grpc_Health_V1_HealthClientInterceptorFactoryProtocol: Sendable {

  /// - Returns: Interceptors to use when invoking 'check'.
  func makeCheckInterceptors() -> [ClientInterceptor<Grpc_Health_V1_HealthCheckRequest, Grpc_Health_V1_HealthCheckResponse>]

  /// - Returns: Interceptors to use when invoking 'watch'.
  func makeWatchInterceptors() -> [ClientInterceptor<Grpc_Health_V1_HealthCheckRequest, Grpc_Health_V1_HealthCheckResponse>]
}

public enum Grpc_Health_V1_HealthClientMetadata {
  public static let serviceDescriptor = GRPCServiceDescriptor(
    name: "Health",
    fullName: "grpc.health.v1.Health",
    methods: [
      Grpc_Health_V1_HealthClientMetadata.Methods.check,
      Grpc_Health_V1_HealthClientMetadata.Methods.watch,
    ]
  )

  public enum Methods {
    public static let check = GRPCMethodDescriptor(
      name: "Check",
      path: "/grpc.health.v1.Health/Check",
      type: GRPCCallType.unary
    )

    public static let watch = GRPCMethodDescriptor(
      name: "Watch",
      path: "/grpc.health.v1.Health/Watch",
      type: GRPCCallType.serverStreaming
    )
  }
}

/// To build a server, implement a class that conforms to this protocol.
public protocol Grpc_Health_V1_HealthProvider: CallHandlerProvider {
  var interceptors: Grpc_Health_V1_HealthServerInterceptorFactoryProtocol? { get }

  func check(request: Grpc_Health_V1_HealthCheckRequest, context: StatusOnlyCallContext) -> EventLoopFuture<Grpc_Health_V1_HealthCheckResponse>

  func watch(request: Grpc_Health_V1_HealthCheckRequest, context: StreamingResponseCallContext<Grpc_Health_V1_HealthCheckResponse>) -> EventLoopFuture<GRPCStatus>
}

extension Grpc_Health_V1_HealthProvider {
  public var serviceName: Substring {
    return Grpc_Health_V1_HealthServerMetadata.serviceDescriptor.fullName[...]
  }

  /// Determines, calls and returns the appropriate request handler, depending on the request's method.
  /// Returns nil for methods not handled by this service.
  public func handle(
    method name: Substring,
    context: CallHandlerContext
  ) -> GRPCServerHandlerProtocol? {
    switch name {
    case "Check":
      return UnaryServerHandler(
        context: context,
        requestDeserializer: ProtobufDeserializer<Grpc_Health_V1_HealthCheckRequest>(),
        responseSerializer: ProtobufSerializer<Grpc_Health_V1_HealthCheckResponse>(),
        interceptors: self.interceptors?.makeCheckInterceptors() ?? [],
        userFunction: self.check(request:context:)
      )

    case "Watch":
      return ServerStreamingServerHandler(
        context: context,
        requestDeserializer: ProtobufDeserializer<Grpc_Health_V1_HealthCheckRequest>(),
        responseSerializer: ProtobufSerializer<Grpc_Health_V1_HealthCheckResponse>(),
        interceptors: self.interceptors?.makeWatchInterceptors() ?? [],
        userFunction: self.watch(request:context:)
      )

    default:
      return nil
    }
  }
}

/// To implement a server, implement an object which conforms to this protocol.
@available(macOS 10.15, iOS 13, tvOS 13, watchOS 6, *)
public protocol Grpc_Health_V1_HealthAsyncProvider: CallHandlerProvider, Sendable {
  static var serviceDescriptor: GRPCServiceDescriptor { get }
  var interceptors: Grpc_Health_V1_HealthServerInterceptorFactoryProtocol? { get }

  func check(
    request: Grpc_Health_V1_HealthCheckRequest,
    context: GRPCAsyncServerCallContext
  ) async throws -> Grpc_Health_V1_HealthCheckResponse

  func watch(
    request: Grpc_Health_V1_HealthCheckRequest,
    responseStream: GRPCAsyncResponseStreamWriter<Grpc_Health_V1_HealthCheckResponse>,
    context: GRPCAsyncServerCallContext
  ) async throws
}

@available(macOS 10.15, iOS 13, tvOS 13, watchOS 6, *)
extension Grpc_Health_V1_HealthAsyncProvider {
  public static var serviceDescriptor: GRPCServiceDescriptor {
    return Grpc_Health_V1_HealthServerMetadata.serviceDescriptor
  }

  public var serviceName: Substring {
    return Grpc_Health_V1_HealthServerMetadata.serviceDescriptor.fullName[...]
  }

  public var interceptors: Grpc_Health_V1_HealthServerInterceptorFactoryProtocol? {
    return nil
  }

  public func handle(
    method name: Substring,
    context: CallHandlerContext
  ) -> GRPCServerHandlerProtocol? {
    switch name {
    case "Check":
      return GRPCAsyncServerHandler(
        context: context,
        requestDeserializer: ProtobufDeserializer<Grpc_Health_V1_HealthCheckRequest>(),
        responseSerializer: ProtobufSerializer<Grpc_Health_V1_HealthCheckResponse>(),
        interceptors: self.interceptors?.makeCheckInterceptors() ?? [],
        wrapping: { try await self.check(request: $0, context: $1) }
      )

    case "Watch":
      return GRPCAsyncServerHandler(
        context: context,
        requestDeserializer: ProtobufDeserializer<Grpc_Health_V1_HealthCheckRequest>(),
        responseSerializer: ProtobufSerializer<Grpc_Health_V1_HealthCheckResponse>(),
        interceptors: self.interceptors?.makeWatchInterceptors() ?? [],
        wrapping: { try await self.watch(request: $0, responseStream: $1, context: $2) }
      )

    default:
      return nil
    }
  }
}

public protocol Grpc_Health_V1_HealthServerInterceptorFactoryProtocol: Sendable {

  /// - Returns: Interceptors to use when handling 'check'.
  ///   Defaults to calling `self.makeInterceptors()`.
  func makeCheckInterceptors() -> [ServerInterceptor<Grpc_Health_V1_HealthCheckRequest, Grpc_Health_V1_HealthCheckResponse>]

  /// - Returns: Interceptors to use when handling 'watch'.
  ///   Defaults to calling `self.makeInterceptors()`.
  func makeWatchInterceptors() -> [ServerInterceptor<Grpc_Health_V1_HealthCheckRequest, Grpc_Health_V1_HealthCheckResponse>]
}

public enum Grpc_Health_V1_HealthServerMetadata {
  public static let serviceDescriptor = GRPCServiceDescriptor(
    name: "Health",
    fullName: "grpc.health.v1.Health",
    methods: [
      Grpc_Health_V1_HealthServerMetadata.Methods.check,
      Grpc_Health_V1_HealthServerMetadata.Methods.watch,
    ]
  )

  public enum Methods {
    public static let check = GRPCMethodDescriptor(
      name: "Check",
      path: "/grpc.health.v1.Health/Check",
      type: GRPCCallType.unary
    )

    public static let watch = GRPCMethodDescriptor(
      name: "Watch",
      path: "/grpc.health.v1.Health/Watch",
      type: GRPCCallType.serverStreaming
    )
  }
}
