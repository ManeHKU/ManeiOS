//
// DO NOT EDIT.
// swift-format-ignore-file
//
// Generated by the protocol buffer compiler.
// Source: main_service.proto
//
import GRPC
import NIO
import NIOConcurrencyHelpers
import SwiftProtobuf


/// Usage: instantiate `Service_MainServiceClient`, then call methods of this protocol to make API calls.
public protocol Service_MainServiceClientProtocol: GRPCClient {
  var serviceName: String { get }
  var interceptors: Service_MainServiceClientInterceptorFactoryProtocol? { get }

  func getUpdatedURLs(
    _ request: Service_GetUpdatedURLsRequest,
    callOptions: CallOptions?
  ) -> UnaryCall<Service_GetUpdatedURLsRequest, Service_GetUpdatedURLsResponse>

  func updateUserInfo(
    _ request: Service_UpdateUserInfoRequest,
    callOptions: CallOptions?
  ) -> UnaryCall<Service_UpdateUserInfoRequest, SwiftProtobuf.Google_Protobuf_Empty>

  func upsertTakenCourses(
    _ request: Service_UpsertTakenCoursesRequest,
    callOptions: CallOptions?
  ) -> UnaryCall<Service_UpsertTakenCoursesRequest, SwiftProtobuf.Google_Protobuf_Empty>

  func listCourses(
    _ request: Service_ListCoursesRequest,
    callOptions: CallOptions?
  ) -> UnaryCall<Service_ListCoursesRequest, Service_CoursesResponse>

  func searchCourses(
    _ request: Service_SearchCourseRequest,
    callOptions: CallOptions?
  ) -> UnaryCall<Service_SearchCourseRequest, Service_CoursesResponse>

  func getCourseDetails(
    _ request: Service_GetCourseDetailRequest,
    callOptions: CallOptions?
  ) -> UnaryCall<Service_GetCourseDetailRequest, Service_GetCourseDetailResponse>

  func addReview(
    _ request: Reviews_AddReviewRequest,
    callOptions: CallOptions?
  ) -> UnaryCall<Reviews_AddReviewRequest, Reviews_AddReviewResponse>
}

extension Service_MainServiceClientProtocol {
  public var serviceName: String {
    return "service.MainService"
  }

  /// Unary call to GetUpdatedURLs
  ///
  /// - Parameters:
  ///   - request: Request to send to GetUpdatedURLs.
  ///   - callOptions: Call options.
  /// - Returns: A `UnaryCall` with futures for the metadata, status and response.
  public func getUpdatedURLs(
    _ request: Service_GetUpdatedURLsRequest,
    callOptions: CallOptions? = nil
  ) -> UnaryCall<Service_GetUpdatedURLsRequest, Service_GetUpdatedURLsResponse> {
    return self.makeUnaryCall(
      path: Service_MainServiceClientMetadata.Methods.getUpdatedURLs.path,
      request: request,
      callOptions: callOptions ?? self.defaultCallOptions,
      interceptors: self.interceptors?.makeGetUpdatedURLsInterceptors() ?? []
    )
  }

  /// Unary call to UpdateUserInfo
  ///
  /// - Parameters:
  ///   - request: Request to send to UpdateUserInfo.
  ///   - callOptions: Call options.
  /// - Returns: A `UnaryCall` with futures for the metadata, status and response.
  public func updateUserInfo(
    _ request: Service_UpdateUserInfoRequest,
    callOptions: CallOptions? = nil
  ) -> UnaryCall<Service_UpdateUserInfoRequest, SwiftProtobuf.Google_Protobuf_Empty> {
    return self.makeUnaryCall(
      path: Service_MainServiceClientMetadata.Methods.updateUserInfo.path,
      request: request,
      callOptions: callOptions ?? self.defaultCallOptions,
      interceptors: self.interceptors?.makeUpdateUserInfoInterceptors() ?? []
    )
  }

  /// Unary call to UpsertTakenCourses
  ///
  /// - Parameters:
  ///   - request: Request to send to UpsertTakenCourses.
  ///   - callOptions: Call options.
  /// - Returns: A `UnaryCall` with futures for the metadata, status and response.
  public func upsertTakenCourses(
    _ request: Service_UpsertTakenCoursesRequest,
    callOptions: CallOptions? = nil
  ) -> UnaryCall<Service_UpsertTakenCoursesRequest, SwiftProtobuf.Google_Protobuf_Empty> {
    return self.makeUnaryCall(
      path: Service_MainServiceClientMetadata.Methods.upsertTakenCourses.path,
      request: request,
      callOptions: callOptions ?? self.defaultCallOptions,
      interceptors: self.interceptors?.makeUpsertTakenCoursesInterceptors() ?? []
    )
  }

  /// Unary call to ListCourses
  ///
  /// - Parameters:
  ///   - request: Request to send to ListCourses.
  ///   - callOptions: Call options.
  /// - Returns: A `UnaryCall` with futures for the metadata, status and response.
  public func listCourses(
    _ request: Service_ListCoursesRequest,
    callOptions: CallOptions? = nil
  ) -> UnaryCall<Service_ListCoursesRequest, Service_CoursesResponse> {
    return self.makeUnaryCall(
      path: Service_MainServiceClientMetadata.Methods.listCourses.path,
      request: request,
      callOptions: callOptions ?? self.defaultCallOptions,
      interceptors: self.interceptors?.makeListCoursesInterceptors() ?? []
    )
  }

  /// Unary call to SearchCourses
  ///
  /// - Parameters:
  ///   - request: Request to send to SearchCourses.
  ///   - callOptions: Call options.
  /// - Returns: A `UnaryCall` with futures for the metadata, status and response.
  public func searchCourses(
    _ request: Service_SearchCourseRequest,
    callOptions: CallOptions? = nil
  ) -> UnaryCall<Service_SearchCourseRequest, Service_CoursesResponse> {
    return self.makeUnaryCall(
      path: Service_MainServiceClientMetadata.Methods.searchCourses.path,
      request: request,
      callOptions: callOptions ?? self.defaultCallOptions,
      interceptors: self.interceptors?.makeSearchCoursesInterceptors() ?? []
    )
  }

  /// Unary call to GetCourseDetails
  ///
  /// - Parameters:
  ///   - request: Request to send to GetCourseDetails.
  ///   - callOptions: Call options.
  /// - Returns: A `UnaryCall` with futures for the metadata, status and response.
  public func getCourseDetails(
    _ request: Service_GetCourseDetailRequest,
    callOptions: CallOptions? = nil
  ) -> UnaryCall<Service_GetCourseDetailRequest, Service_GetCourseDetailResponse> {
    return self.makeUnaryCall(
      path: Service_MainServiceClientMetadata.Methods.getCourseDetails.path,
      request: request,
      callOptions: callOptions ?? self.defaultCallOptions,
      interceptors: self.interceptors?.makeGetCourseDetailsInterceptors() ?? []
    )
  }

  /// Unary call to AddReview
  ///
  /// - Parameters:
  ///   - request: Request to send to AddReview.
  ///   - callOptions: Call options.
  /// - Returns: A `UnaryCall` with futures for the metadata, status and response.
  public func addReview(
    _ request: Reviews_AddReviewRequest,
    callOptions: CallOptions? = nil
  ) -> UnaryCall<Reviews_AddReviewRequest, Reviews_AddReviewResponse> {
    return self.makeUnaryCall(
      path: Service_MainServiceClientMetadata.Methods.addReview.path,
      request: request,
      callOptions: callOptions ?? self.defaultCallOptions,
      interceptors: self.interceptors?.makeAddReviewInterceptors() ?? []
    )
  }
}

@available(*, deprecated)
extension Service_MainServiceClient: @unchecked Sendable {}

@available(*, deprecated, renamed: "Service_MainServiceNIOClient")
public final class Service_MainServiceClient: Service_MainServiceClientProtocol {
  private let lock = Lock()
  private var _defaultCallOptions: CallOptions
  private var _interceptors: Service_MainServiceClientInterceptorFactoryProtocol?
  public let channel: GRPCChannel
  public var defaultCallOptions: CallOptions {
    get { self.lock.withLock { return self._defaultCallOptions } }
    set { self.lock.withLockVoid { self._defaultCallOptions = newValue } }
  }
  public var interceptors: Service_MainServiceClientInterceptorFactoryProtocol? {
    get { self.lock.withLock { return self._interceptors } }
    set { self.lock.withLockVoid { self._interceptors = newValue } }
  }

  /// Creates a client for the service.MainService service.
  ///
  /// - Parameters:
  ///   - channel: `GRPCChannel` to the service host.
  ///   - defaultCallOptions: Options to use for each service call if the user doesn't provide them.
  ///   - interceptors: A factory providing interceptors for each RPC.
  public init(
    channel: GRPCChannel,
    defaultCallOptions: CallOptions = CallOptions(),
    interceptors: Service_MainServiceClientInterceptorFactoryProtocol? = nil
  ) {
    self.channel = channel
    self._defaultCallOptions = defaultCallOptions
    self._interceptors = interceptors
  }
}

public struct Service_MainServiceNIOClient: Service_MainServiceClientProtocol {
  public var channel: GRPCChannel
  public var defaultCallOptions: CallOptions
  public var interceptors: Service_MainServiceClientInterceptorFactoryProtocol?

  /// Creates a client for the service.MainService service.
  ///
  /// - Parameters:
  ///   - channel: `GRPCChannel` to the service host.
  ///   - defaultCallOptions: Options to use for each service call if the user doesn't provide them.
  ///   - interceptors: A factory providing interceptors for each RPC.
  public init(
    channel: GRPCChannel,
    defaultCallOptions: CallOptions = CallOptions(),
    interceptors: Service_MainServiceClientInterceptorFactoryProtocol? = nil
  ) {
    self.channel = channel
    self.defaultCallOptions = defaultCallOptions
    self.interceptors = interceptors
  }
}

@available(macOS 10.15, iOS 13, tvOS 13, watchOS 6, *)
public protocol Service_MainServiceAsyncClientProtocol: GRPCClient {
  static var serviceDescriptor: GRPCServiceDescriptor { get }
  var interceptors: Service_MainServiceClientInterceptorFactoryProtocol? { get }

  func makeGetUpdatedUrlsCall(
    _ request: Service_GetUpdatedURLsRequest,
    callOptions: CallOptions?
  ) -> GRPCAsyncUnaryCall<Service_GetUpdatedURLsRequest, Service_GetUpdatedURLsResponse>

  func makeUpdateUserInfoCall(
    _ request: Service_UpdateUserInfoRequest,
    callOptions: CallOptions?
  ) -> GRPCAsyncUnaryCall<Service_UpdateUserInfoRequest, SwiftProtobuf.Google_Protobuf_Empty>

  func makeUpsertTakenCoursesCall(
    _ request: Service_UpsertTakenCoursesRequest,
    callOptions: CallOptions?
  ) -> GRPCAsyncUnaryCall<Service_UpsertTakenCoursesRequest, SwiftProtobuf.Google_Protobuf_Empty>

  func makeListCoursesCall(
    _ request: Service_ListCoursesRequest,
    callOptions: CallOptions?
  ) -> GRPCAsyncUnaryCall<Service_ListCoursesRequest, Service_CoursesResponse>

  func makeSearchCoursesCall(
    _ request: Service_SearchCourseRequest,
    callOptions: CallOptions?
  ) -> GRPCAsyncUnaryCall<Service_SearchCourseRequest, Service_CoursesResponse>

  func makeGetCourseDetailsCall(
    _ request: Service_GetCourseDetailRequest,
    callOptions: CallOptions?
  ) -> GRPCAsyncUnaryCall<Service_GetCourseDetailRequest, Service_GetCourseDetailResponse>

  func makeAddReviewCall(
    _ request: Reviews_AddReviewRequest,
    callOptions: CallOptions?
  ) -> GRPCAsyncUnaryCall<Reviews_AddReviewRequest, Reviews_AddReviewResponse>
}

@available(macOS 10.15, iOS 13, tvOS 13, watchOS 6, *)
extension Service_MainServiceAsyncClientProtocol {
  public static var serviceDescriptor: GRPCServiceDescriptor {
    return Service_MainServiceClientMetadata.serviceDescriptor
  }

  public var interceptors: Service_MainServiceClientInterceptorFactoryProtocol? {
    return nil
  }

  public func makeGetUpdatedUrlsCall(
    _ request: Service_GetUpdatedURLsRequest,
    callOptions: CallOptions? = nil
  ) -> GRPCAsyncUnaryCall<Service_GetUpdatedURLsRequest, Service_GetUpdatedURLsResponse> {
    return self.makeAsyncUnaryCall(
      path: Service_MainServiceClientMetadata.Methods.getUpdatedURLs.path,
      request: request,
      callOptions: callOptions ?? self.defaultCallOptions,
      interceptors: self.interceptors?.makeGetUpdatedURLsInterceptors() ?? []
    )
  }

  public func makeUpdateUserInfoCall(
    _ request: Service_UpdateUserInfoRequest,
    callOptions: CallOptions? = nil
  ) -> GRPCAsyncUnaryCall<Service_UpdateUserInfoRequest, SwiftProtobuf.Google_Protobuf_Empty> {
    return self.makeAsyncUnaryCall(
      path: Service_MainServiceClientMetadata.Methods.updateUserInfo.path,
      request: request,
      callOptions: callOptions ?? self.defaultCallOptions,
      interceptors: self.interceptors?.makeUpdateUserInfoInterceptors() ?? []
    )
  }

  public func makeUpsertTakenCoursesCall(
    _ request: Service_UpsertTakenCoursesRequest,
    callOptions: CallOptions? = nil
  ) -> GRPCAsyncUnaryCall<Service_UpsertTakenCoursesRequest, SwiftProtobuf.Google_Protobuf_Empty> {
    return self.makeAsyncUnaryCall(
      path: Service_MainServiceClientMetadata.Methods.upsertTakenCourses.path,
      request: request,
      callOptions: callOptions ?? self.defaultCallOptions,
      interceptors: self.interceptors?.makeUpsertTakenCoursesInterceptors() ?? []
    )
  }

  public func makeListCoursesCall(
    _ request: Service_ListCoursesRequest,
    callOptions: CallOptions? = nil
  ) -> GRPCAsyncUnaryCall<Service_ListCoursesRequest, Service_CoursesResponse> {
    return self.makeAsyncUnaryCall(
      path: Service_MainServiceClientMetadata.Methods.listCourses.path,
      request: request,
      callOptions: callOptions ?? self.defaultCallOptions,
      interceptors: self.interceptors?.makeListCoursesInterceptors() ?? []
    )
  }

  public func makeSearchCoursesCall(
    _ request: Service_SearchCourseRequest,
    callOptions: CallOptions? = nil
  ) -> GRPCAsyncUnaryCall<Service_SearchCourseRequest, Service_CoursesResponse> {
    return self.makeAsyncUnaryCall(
      path: Service_MainServiceClientMetadata.Methods.searchCourses.path,
      request: request,
      callOptions: callOptions ?? self.defaultCallOptions,
      interceptors: self.interceptors?.makeSearchCoursesInterceptors() ?? []
    )
  }

  public func makeGetCourseDetailsCall(
    _ request: Service_GetCourseDetailRequest,
    callOptions: CallOptions? = nil
  ) -> GRPCAsyncUnaryCall<Service_GetCourseDetailRequest, Service_GetCourseDetailResponse> {
    return self.makeAsyncUnaryCall(
      path: Service_MainServiceClientMetadata.Methods.getCourseDetails.path,
      request: request,
      callOptions: callOptions ?? self.defaultCallOptions,
      interceptors: self.interceptors?.makeGetCourseDetailsInterceptors() ?? []
    )
  }

  public func makeAddReviewCall(
    _ request: Reviews_AddReviewRequest,
    callOptions: CallOptions? = nil
  ) -> GRPCAsyncUnaryCall<Reviews_AddReviewRequest, Reviews_AddReviewResponse> {
    return self.makeAsyncUnaryCall(
      path: Service_MainServiceClientMetadata.Methods.addReview.path,
      request: request,
      callOptions: callOptions ?? self.defaultCallOptions,
      interceptors: self.interceptors?.makeAddReviewInterceptors() ?? []
    )
  }
}

@available(macOS 10.15, iOS 13, tvOS 13, watchOS 6, *)
extension Service_MainServiceAsyncClientProtocol {
  public func getUpdatedURLs(
    _ request: Service_GetUpdatedURLsRequest,
    callOptions: CallOptions? = nil
  ) async throws -> Service_GetUpdatedURLsResponse {
    return try await self.performAsyncUnaryCall(
      path: Service_MainServiceClientMetadata.Methods.getUpdatedURLs.path,
      request: request,
      callOptions: callOptions ?? self.defaultCallOptions,
      interceptors: self.interceptors?.makeGetUpdatedURLsInterceptors() ?? []
    )
  }

  public func updateUserInfo(
    _ request: Service_UpdateUserInfoRequest,
    callOptions: CallOptions? = nil
  ) async throws -> SwiftProtobuf.Google_Protobuf_Empty {
    return try await self.performAsyncUnaryCall(
      path: Service_MainServiceClientMetadata.Methods.updateUserInfo.path,
      request: request,
      callOptions: callOptions ?? self.defaultCallOptions,
      interceptors: self.interceptors?.makeUpdateUserInfoInterceptors() ?? []
    )
  }

  public func upsertTakenCourses(
    _ request: Service_UpsertTakenCoursesRequest,
    callOptions: CallOptions? = nil
  ) async throws -> SwiftProtobuf.Google_Protobuf_Empty {
    return try await self.performAsyncUnaryCall(
      path: Service_MainServiceClientMetadata.Methods.upsertTakenCourses.path,
      request: request,
      callOptions: callOptions ?? self.defaultCallOptions,
      interceptors: self.interceptors?.makeUpsertTakenCoursesInterceptors() ?? []
    )
  }

  public func listCourses(
    _ request: Service_ListCoursesRequest,
    callOptions: CallOptions? = nil
  ) async throws -> Service_CoursesResponse {
    return try await self.performAsyncUnaryCall(
      path: Service_MainServiceClientMetadata.Methods.listCourses.path,
      request: request,
      callOptions: callOptions ?? self.defaultCallOptions,
      interceptors: self.interceptors?.makeListCoursesInterceptors() ?? []
    )
  }

  public func searchCourses(
    _ request: Service_SearchCourseRequest,
    callOptions: CallOptions? = nil
  ) async throws -> Service_CoursesResponse {
    return try await self.performAsyncUnaryCall(
      path: Service_MainServiceClientMetadata.Methods.searchCourses.path,
      request: request,
      callOptions: callOptions ?? self.defaultCallOptions,
      interceptors: self.interceptors?.makeSearchCoursesInterceptors() ?? []
    )
  }

  public func getCourseDetails(
    _ request: Service_GetCourseDetailRequest,
    callOptions: CallOptions? = nil
  ) async throws -> Service_GetCourseDetailResponse {
    return try await self.performAsyncUnaryCall(
      path: Service_MainServiceClientMetadata.Methods.getCourseDetails.path,
      request: request,
      callOptions: callOptions ?? self.defaultCallOptions,
      interceptors: self.interceptors?.makeGetCourseDetailsInterceptors() ?? []
    )
  }

  public func addReview(
    _ request: Reviews_AddReviewRequest,
    callOptions: CallOptions? = nil
  ) async throws -> Reviews_AddReviewResponse {
    return try await self.performAsyncUnaryCall(
      path: Service_MainServiceClientMetadata.Methods.addReview.path,
      request: request,
      callOptions: callOptions ?? self.defaultCallOptions,
      interceptors: self.interceptors?.makeAddReviewInterceptors() ?? []
    )
  }
}

@available(macOS 10.15, iOS 13, tvOS 13, watchOS 6, *)
public struct Service_MainServiceAsyncClient: Service_MainServiceAsyncClientProtocol {
  public var channel: GRPCChannel
  public var defaultCallOptions: CallOptions
  public var interceptors: Service_MainServiceClientInterceptorFactoryProtocol?

  public init(
    channel: GRPCChannel,
    defaultCallOptions: CallOptions = CallOptions(),
    interceptors: Service_MainServiceClientInterceptorFactoryProtocol? = nil
  ) {
    self.channel = channel
    self.defaultCallOptions = defaultCallOptions
    self.interceptors = interceptors
  }
}

public protocol Service_MainServiceClientInterceptorFactoryProtocol: Sendable {

  /// - Returns: Interceptors to use when invoking 'getUpdatedURLs'.
  func makeGetUpdatedURLsInterceptors() -> [ClientInterceptor<Service_GetUpdatedURLsRequest, Service_GetUpdatedURLsResponse>]

  /// - Returns: Interceptors to use when invoking 'updateUserInfo'.
  func makeUpdateUserInfoInterceptors() -> [ClientInterceptor<Service_UpdateUserInfoRequest, SwiftProtobuf.Google_Protobuf_Empty>]

  /// - Returns: Interceptors to use when invoking 'upsertTakenCourses'.
  func makeUpsertTakenCoursesInterceptors() -> [ClientInterceptor<Service_UpsertTakenCoursesRequest, SwiftProtobuf.Google_Protobuf_Empty>]

  /// - Returns: Interceptors to use when invoking 'listCourses'.
  func makeListCoursesInterceptors() -> [ClientInterceptor<Service_ListCoursesRequest, Service_CoursesResponse>]

  /// - Returns: Interceptors to use when invoking 'searchCourses'.
  func makeSearchCoursesInterceptors() -> [ClientInterceptor<Service_SearchCourseRequest, Service_CoursesResponse>]

  /// - Returns: Interceptors to use when invoking 'getCourseDetails'.
  func makeGetCourseDetailsInterceptors() -> [ClientInterceptor<Service_GetCourseDetailRequest, Service_GetCourseDetailResponse>]

  /// - Returns: Interceptors to use when invoking 'addReview'.
  func makeAddReviewInterceptors() -> [ClientInterceptor<Reviews_AddReviewRequest, Reviews_AddReviewResponse>]
}

public enum Service_MainServiceClientMetadata {
  public static let serviceDescriptor = GRPCServiceDescriptor(
    name: "MainService",
    fullName: "service.MainService",
    methods: [
      Service_MainServiceClientMetadata.Methods.getUpdatedURLs,
      Service_MainServiceClientMetadata.Methods.updateUserInfo,
      Service_MainServiceClientMetadata.Methods.upsertTakenCourses,
      Service_MainServiceClientMetadata.Methods.listCourses,
      Service_MainServiceClientMetadata.Methods.searchCourses,
      Service_MainServiceClientMetadata.Methods.getCourseDetails,
      Service_MainServiceClientMetadata.Methods.addReview,
    ]
  )

  public enum Methods {
    public static let getUpdatedURLs = GRPCMethodDescriptor(
      name: "GetUpdatedURLs",
      path: "/service.MainService/GetUpdatedURLs",
      type: GRPCCallType.unary
    )

    public static let updateUserInfo = GRPCMethodDescriptor(
      name: "UpdateUserInfo",
      path: "/service.MainService/UpdateUserInfo",
      type: GRPCCallType.unary
    )

    public static let upsertTakenCourses = GRPCMethodDescriptor(
      name: "UpsertTakenCourses",
      path: "/service.MainService/UpsertTakenCourses",
      type: GRPCCallType.unary
    )

    public static let listCourses = GRPCMethodDescriptor(
      name: "ListCourses",
      path: "/service.MainService/ListCourses",
      type: GRPCCallType.unary
    )

    public static let searchCourses = GRPCMethodDescriptor(
      name: "SearchCourses",
      path: "/service.MainService/SearchCourses",
      type: GRPCCallType.unary
    )

    public static let getCourseDetails = GRPCMethodDescriptor(
      name: "GetCourseDetails",
      path: "/service.MainService/GetCourseDetails",
      type: GRPCCallType.unary
    )

    public static let addReview = GRPCMethodDescriptor(
      name: "AddReview",
      path: "/service.MainService/AddReview",
      type: GRPCCallType.unary
    )
  }
}

/// To build a server, implement a class that conforms to this protocol.
public protocol Service_MainServiceProvider: CallHandlerProvider {
  var interceptors: Service_MainServiceServerInterceptorFactoryProtocol? { get }

  func getUpdatedURLs(request: Service_GetUpdatedURLsRequest, context: StatusOnlyCallContext) -> EventLoopFuture<Service_GetUpdatedURLsResponse>

  func updateUserInfo(request: Service_UpdateUserInfoRequest, context: StatusOnlyCallContext) -> EventLoopFuture<SwiftProtobuf.Google_Protobuf_Empty>

  func upsertTakenCourses(request: Service_UpsertTakenCoursesRequest, context: StatusOnlyCallContext) -> EventLoopFuture<SwiftProtobuf.Google_Protobuf_Empty>

  func listCourses(request: Service_ListCoursesRequest, context: StatusOnlyCallContext) -> EventLoopFuture<Service_CoursesResponse>

  func searchCourses(request: Service_SearchCourseRequest, context: StatusOnlyCallContext) -> EventLoopFuture<Service_CoursesResponse>

  func getCourseDetails(request: Service_GetCourseDetailRequest, context: StatusOnlyCallContext) -> EventLoopFuture<Service_GetCourseDetailResponse>

  func addReview(request: Reviews_AddReviewRequest, context: StatusOnlyCallContext) -> EventLoopFuture<Reviews_AddReviewResponse>
}

extension Service_MainServiceProvider {
  public var serviceName: Substring {
    return Service_MainServiceServerMetadata.serviceDescriptor.fullName[...]
  }

  /// Determines, calls and returns the appropriate request handler, depending on the request's method.
  /// Returns nil for methods not handled by this service.
  public func handle(
    method name: Substring,
    context: CallHandlerContext
  ) -> GRPCServerHandlerProtocol? {
    switch name {
    case "GetUpdatedURLs":
      return UnaryServerHandler(
        context: context,
        requestDeserializer: ProtobufDeserializer<Service_GetUpdatedURLsRequest>(),
        responseSerializer: ProtobufSerializer<Service_GetUpdatedURLsResponse>(),
        interceptors: self.interceptors?.makeGetUpdatedURLsInterceptors() ?? [],
        userFunction: self.getUpdatedURLs(request:context:)
      )

    case "UpdateUserInfo":
      return UnaryServerHandler(
        context: context,
        requestDeserializer: ProtobufDeserializer<Service_UpdateUserInfoRequest>(),
        responseSerializer: ProtobufSerializer<SwiftProtobuf.Google_Protobuf_Empty>(),
        interceptors: self.interceptors?.makeUpdateUserInfoInterceptors() ?? [],
        userFunction: self.updateUserInfo(request:context:)
      )

    case "UpsertTakenCourses":
      return UnaryServerHandler(
        context: context,
        requestDeserializer: ProtobufDeserializer<Service_UpsertTakenCoursesRequest>(),
        responseSerializer: ProtobufSerializer<SwiftProtobuf.Google_Protobuf_Empty>(),
        interceptors: self.interceptors?.makeUpsertTakenCoursesInterceptors() ?? [],
        userFunction: self.upsertTakenCourses(request:context:)
      )

    case "ListCourses":
      return UnaryServerHandler(
        context: context,
        requestDeserializer: ProtobufDeserializer<Service_ListCoursesRequest>(),
        responseSerializer: ProtobufSerializer<Service_CoursesResponse>(),
        interceptors: self.interceptors?.makeListCoursesInterceptors() ?? [],
        userFunction: self.listCourses(request:context:)
      )

    case "SearchCourses":
      return UnaryServerHandler(
        context: context,
        requestDeserializer: ProtobufDeserializer<Service_SearchCourseRequest>(),
        responseSerializer: ProtobufSerializer<Service_CoursesResponse>(),
        interceptors: self.interceptors?.makeSearchCoursesInterceptors() ?? [],
        userFunction: self.searchCourses(request:context:)
      )

    case "GetCourseDetails":
      return UnaryServerHandler(
        context: context,
        requestDeserializer: ProtobufDeserializer<Service_GetCourseDetailRequest>(),
        responseSerializer: ProtobufSerializer<Service_GetCourseDetailResponse>(),
        interceptors: self.interceptors?.makeGetCourseDetailsInterceptors() ?? [],
        userFunction: self.getCourseDetails(request:context:)
      )

    case "AddReview":
      return UnaryServerHandler(
        context: context,
        requestDeserializer: ProtobufDeserializer<Reviews_AddReviewRequest>(),
        responseSerializer: ProtobufSerializer<Reviews_AddReviewResponse>(),
        interceptors: self.interceptors?.makeAddReviewInterceptors() ?? [],
        userFunction: self.addReview(request:context:)
      )

    default:
      return nil
    }
  }
}

/// To implement a server, implement an object which conforms to this protocol.
@available(macOS 10.15, iOS 13, tvOS 13, watchOS 6, *)
public protocol Service_MainServiceAsyncProvider: CallHandlerProvider, Sendable {
  static var serviceDescriptor: GRPCServiceDescriptor { get }
  var interceptors: Service_MainServiceServerInterceptorFactoryProtocol? { get }

  func getUpdatedURLs(
    request: Service_GetUpdatedURLsRequest,
    context: GRPCAsyncServerCallContext
  ) async throws -> Service_GetUpdatedURLsResponse

  func updateUserInfo(
    request: Service_UpdateUserInfoRequest,
    context: GRPCAsyncServerCallContext
  ) async throws -> SwiftProtobuf.Google_Protobuf_Empty

  func upsertTakenCourses(
    request: Service_UpsertTakenCoursesRequest,
    context: GRPCAsyncServerCallContext
  ) async throws -> SwiftProtobuf.Google_Protobuf_Empty

  func listCourses(
    request: Service_ListCoursesRequest,
    context: GRPCAsyncServerCallContext
  ) async throws -> Service_CoursesResponse

  func searchCourses(
    request: Service_SearchCourseRequest,
    context: GRPCAsyncServerCallContext
  ) async throws -> Service_CoursesResponse

  func getCourseDetails(
    request: Service_GetCourseDetailRequest,
    context: GRPCAsyncServerCallContext
  ) async throws -> Service_GetCourseDetailResponse

  func addReview(
    request: Reviews_AddReviewRequest,
    context: GRPCAsyncServerCallContext
  ) async throws -> Reviews_AddReviewResponse
}

@available(macOS 10.15, iOS 13, tvOS 13, watchOS 6, *)
extension Service_MainServiceAsyncProvider {
  public static var serviceDescriptor: GRPCServiceDescriptor {
    return Service_MainServiceServerMetadata.serviceDescriptor
  }

  public var serviceName: Substring {
    return Service_MainServiceServerMetadata.serviceDescriptor.fullName[...]
  }

  public var interceptors: Service_MainServiceServerInterceptorFactoryProtocol? {
    return nil
  }

  public func handle(
    method name: Substring,
    context: CallHandlerContext
  ) -> GRPCServerHandlerProtocol? {
    switch name {
    case "GetUpdatedURLs":
      return GRPCAsyncServerHandler(
        context: context,
        requestDeserializer: ProtobufDeserializer<Service_GetUpdatedURLsRequest>(),
        responseSerializer: ProtobufSerializer<Service_GetUpdatedURLsResponse>(),
        interceptors: self.interceptors?.makeGetUpdatedURLsInterceptors() ?? [],
        wrapping: { try await self.getUpdatedURLs(request: $0, context: $1) }
      )

    case "UpdateUserInfo":
      return GRPCAsyncServerHandler(
        context: context,
        requestDeserializer: ProtobufDeserializer<Service_UpdateUserInfoRequest>(),
        responseSerializer: ProtobufSerializer<SwiftProtobuf.Google_Protobuf_Empty>(),
        interceptors: self.interceptors?.makeUpdateUserInfoInterceptors() ?? [],
        wrapping: { try await self.updateUserInfo(request: $0, context: $1) }
      )

    case "UpsertTakenCourses":
      return GRPCAsyncServerHandler(
        context: context,
        requestDeserializer: ProtobufDeserializer<Service_UpsertTakenCoursesRequest>(),
        responseSerializer: ProtobufSerializer<SwiftProtobuf.Google_Protobuf_Empty>(),
        interceptors: self.interceptors?.makeUpsertTakenCoursesInterceptors() ?? [],
        wrapping: { try await self.upsertTakenCourses(request: $0, context: $1) }
      )

    case "ListCourses":
      return GRPCAsyncServerHandler(
        context: context,
        requestDeserializer: ProtobufDeserializer<Service_ListCoursesRequest>(),
        responseSerializer: ProtobufSerializer<Service_CoursesResponse>(),
        interceptors: self.interceptors?.makeListCoursesInterceptors() ?? [],
        wrapping: { try await self.listCourses(request: $0, context: $1) }
      )

    case "SearchCourses":
      return GRPCAsyncServerHandler(
        context: context,
        requestDeserializer: ProtobufDeserializer<Service_SearchCourseRequest>(),
        responseSerializer: ProtobufSerializer<Service_CoursesResponse>(),
        interceptors: self.interceptors?.makeSearchCoursesInterceptors() ?? [],
        wrapping: { try await self.searchCourses(request: $0, context: $1) }
      )

    case "GetCourseDetails":
      return GRPCAsyncServerHandler(
        context: context,
        requestDeserializer: ProtobufDeserializer<Service_GetCourseDetailRequest>(),
        responseSerializer: ProtobufSerializer<Service_GetCourseDetailResponse>(),
        interceptors: self.interceptors?.makeGetCourseDetailsInterceptors() ?? [],
        wrapping: { try await self.getCourseDetails(request: $0, context: $1) }
      )

    case "AddReview":
      return GRPCAsyncServerHandler(
        context: context,
        requestDeserializer: ProtobufDeserializer<Reviews_AddReviewRequest>(),
        responseSerializer: ProtobufSerializer<Reviews_AddReviewResponse>(),
        interceptors: self.interceptors?.makeAddReviewInterceptors() ?? [],
        wrapping: { try await self.addReview(request: $0, context: $1) }
      )

    default:
      return nil
    }
  }
}

public protocol Service_MainServiceServerInterceptorFactoryProtocol: Sendable {

  /// - Returns: Interceptors to use when handling 'getUpdatedURLs'.
  ///   Defaults to calling `self.makeInterceptors()`.
  func makeGetUpdatedURLsInterceptors() -> [ServerInterceptor<Service_GetUpdatedURLsRequest, Service_GetUpdatedURLsResponse>]

  /// - Returns: Interceptors to use when handling 'updateUserInfo'.
  ///   Defaults to calling `self.makeInterceptors()`.
  func makeUpdateUserInfoInterceptors() -> [ServerInterceptor<Service_UpdateUserInfoRequest, SwiftProtobuf.Google_Protobuf_Empty>]

  /// - Returns: Interceptors to use when handling 'upsertTakenCourses'.
  ///   Defaults to calling `self.makeInterceptors()`.
  func makeUpsertTakenCoursesInterceptors() -> [ServerInterceptor<Service_UpsertTakenCoursesRequest, SwiftProtobuf.Google_Protobuf_Empty>]

  /// - Returns: Interceptors to use when handling 'listCourses'.
  ///   Defaults to calling `self.makeInterceptors()`.
  func makeListCoursesInterceptors() -> [ServerInterceptor<Service_ListCoursesRequest, Service_CoursesResponse>]

  /// - Returns: Interceptors to use when handling 'searchCourses'.
  ///   Defaults to calling `self.makeInterceptors()`.
  func makeSearchCoursesInterceptors() -> [ServerInterceptor<Service_SearchCourseRequest, Service_CoursesResponse>]

  /// - Returns: Interceptors to use when handling 'getCourseDetails'.
  ///   Defaults to calling `self.makeInterceptors()`.
  func makeGetCourseDetailsInterceptors() -> [ServerInterceptor<Service_GetCourseDetailRequest, Service_GetCourseDetailResponse>]

  /// - Returns: Interceptors to use when handling 'addReview'.
  ///   Defaults to calling `self.makeInterceptors()`.
  func makeAddReviewInterceptors() -> [ServerInterceptor<Reviews_AddReviewRequest, Reviews_AddReviewResponse>]
}

public enum Service_MainServiceServerMetadata {
  public static let serviceDescriptor = GRPCServiceDescriptor(
    name: "MainService",
    fullName: "service.MainService",
    methods: [
      Service_MainServiceServerMetadata.Methods.getUpdatedURLs,
      Service_MainServiceServerMetadata.Methods.updateUserInfo,
      Service_MainServiceServerMetadata.Methods.upsertTakenCourses,
      Service_MainServiceServerMetadata.Methods.listCourses,
      Service_MainServiceServerMetadata.Methods.searchCourses,
      Service_MainServiceServerMetadata.Methods.getCourseDetails,
      Service_MainServiceServerMetadata.Methods.addReview,
    ]
  )

  public enum Methods {
    public static let getUpdatedURLs = GRPCMethodDescriptor(
      name: "GetUpdatedURLs",
      path: "/service.MainService/GetUpdatedURLs",
      type: GRPCCallType.unary
    )

    public static let updateUserInfo = GRPCMethodDescriptor(
      name: "UpdateUserInfo",
      path: "/service.MainService/UpdateUserInfo",
      type: GRPCCallType.unary
    )

    public static let upsertTakenCourses = GRPCMethodDescriptor(
      name: "UpsertTakenCourses",
      path: "/service.MainService/UpsertTakenCourses",
      type: GRPCCallType.unary
    )

    public static let listCourses = GRPCMethodDescriptor(
      name: "ListCourses",
      path: "/service.MainService/ListCourses",
      type: GRPCCallType.unary
    )

    public static let searchCourses = GRPCMethodDescriptor(
      name: "SearchCourses",
      path: "/service.MainService/SearchCourses",
      type: GRPCCallType.unary
    )

    public static let getCourseDetails = GRPCMethodDescriptor(
      name: "GetCourseDetails",
      path: "/service.MainService/GetCourseDetails",
      type: GRPCCallType.unary
    )

    public static let addReview = GRPCMethodDescriptor(
      name: "AddReview",
      path: "/service.MainService/AddReview",
      type: GRPCCallType.unary
    )
  }
}
