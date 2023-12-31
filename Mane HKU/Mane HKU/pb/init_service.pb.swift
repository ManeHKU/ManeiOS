// DO NOT EDIT.
// swift-format-ignore-file
//
// Generated by the Swift generator plugin for the protocol buffer compiler.
// Source: init_service.proto
//
// For information on using the generated types, please see the documentation:
//   https://github.com/apple/swift-protobuf/

import Foundation
import SwiftProtobuf

// If the compiler emits an error on this type, it is because this file
// was generated by a version of the `protoc` Swift plug-in that is
// incompatible with the version of SwiftProtobuf to which you are linking.
// Please ensure that you are building against the same version of the API
// that was used to generate this file.
fileprivate struct _GeneratedWithProtocGenSwiftVersion: SwiftProtobuf.ProtobufAPIVersionCheck {
  struct _2: SwiftProtobuf.ProtobufAPIVersion_2 {}
  typealias Version = _2
}

public struct GetInitialConfigRequest {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  public var versionTimestamp: SwiftProtobuf.Google_Protobuf_Timestamp {
    get {return _versionTimestamp ?? SwiftProtobuf.Google_Protobuf_Timestamp()}
    set {_versionTimestamp = newValue}
  }
  /// Returns true if `versionTimestamp` has been explicitly set.
  public var hasVersionTimestamp: Bool {return self._versionTimestamp != nil}
  /// Clears the value of `versionTimestamp`. Subsequent reads from it will return its default value.
  public mutating func clearVersionTimestamp() {self._versionTimestamp = nil}

  public var unknownFields = SwiftProtobuf.UnknownStorage()

  public init() {}

  fileprivate var _versionTimestamp: SwiftProtobuf.Google_Protobuf_Timestamp? = nil
}

public struct GetInitialConfigResponse {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  public var latestUrls: URLsList {
    get {return _latestUrls ?? URLsList()}
    set {_latestUrls = newValue}
  }
  /// Returns true if `latestUrls` has been explicitly set.
  public var hasLatestUrls: Bool {return self._latestUrls != nil}
  /// Clears the value of `latestUrls`. Subsequent reads from it will return its default value.
  public mutating func clearLatestUrls() {self._latestUrls = nil}

  public var unknownFields = SwiftProtobuf.UnknownStorage()

  public init() {}

  fileprivate var _latestUrls: URLsList? = nil
}

public struct URLsList {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  public var versionTimestamp: SwiftProtobuf.Google_Protobuf_Timestamp {
    get {return _versionTimestamp ?? SwiftProtobuf.Google_Protobuf_Timestamp()}
    set {_versionTimestamp = newValue}
  }
  /// Returns true if `versionTimestamp` has been explicitly set.
  public var hasVersionTimestamp: Bool {return self._versionTimestamp != nil}
  /// Clears the value of `versionTimestamp`. Subsequent reads from it will return its default value.
  public mutating func clearVersionTimestamp() {self._versionTimestamp = nil}

  public var supabaseURL: String = String()

  public var supabaseKey: String = String()

  public var unknownFields = SwiftProtobuf.UnknownStorage()

  public init() {}

  fileprivate var _versionTimestamp: SwiftProtobuf.Google_Protobuf_Timestamp? = nil
}

#if swift(>=5.5) && canImport(_Concurrency)
extension GetInitialConfigRequest: @unchecked Sendable {}
extension GetInitialConfigResponse: @unchecked Sendable {}
extension URLsList: @unchecked Sendable {}
#endif  // swift(>=5.5) && canImport(_Concurrency)

// MARK: - Code below here is support for the SwiftProtobuf runtime.

extension GetInitialConfigRequest: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = "GetInitialConfigRequest"
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "versionTimestamp"),
  ]

  public mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularMessageField(value: &self._versionTimestamp) }()
      default: break
      }
    }
  }

  public func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    // The use of inline closures is to circumvent an issue where the compiler
    // allocates stack space for every if/case branch local when no optimizations
    // are enabled. https://github.com/apple/swift-protobuf/issues/1034 and
    // https://github.com/apple/swift-protobuf/issues/1182
    try { if let v = self._versionTimestamp {
      try visitor.visitSingularMessageField(value: v, fieldNumber: 1)
    } }()
    try unknownFields.traverse(visitor: &visitor)
  }

  public static func ==(lhs: GetInitialConfigRequest, rhs: GetInitialConfigRequest) -> Bool {
    if lhs._versionTimestamp != rhs._versionTimestamp {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension GetInitialConfigResponse: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = "GetInitialConfigResponse"
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "latestURLs"),
  ]

  public mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularMessageField(value: &self._latestUrls) }()
      default: break
      }
    }
  }

  public func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    // The use of inline closures is to circumvent an issue where the compiler
    // allocates stack space for every if/case branch local when no optimizations
    // are enabled. https://github.com/apple/swift-protobuf/issues/1034 and
    // https://github.com/apple/swift-protobuf/issues/1182
    try { if let v = self._latestUrls {
      try visitor.visitSingularMessageField(value: v, fieldNumber: 1)
    } }()
    try unknownFields.traverse(visitor: &visitor)
  }

  public static func ==(lhs: GetInitialConfigResponse, rhs: GetInitialConfigResponse) -> Bool {
    if lhs._latestUrls != rhs._latestUrls {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension URLsList: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = "URLsList"
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "versionTimestamp"),
    2: .same(proto: "supabaseURL"),
    3: .same(proto: "supabaseKey"),
  ]

  public mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularMessageField(value: &self._versionTimestamp) }()
      case 2: try { try decoder.decodeSingularStringField(value: &self.supabaseURL) }()
      case 3: try { try decoder.decodeSingularStringField(value: &self.supabaseKey) }()
      default: break
      }
    }
  }

  public func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    // The use of inline closures is to circumvent an issue where the compiler
    // allocates stack space for every if/case branch local when no optimizations
    // are enabled. https://github.com/apple/swift-protobuf/issues/1034 and
    // https://github.com/apple/swift-protobuf/issues/1182
    try { if let v = self._versionTimestamp {
      try visitor.visitSingularMessageField(value: v, fieldNumber: 1)
    } }()
    if !self.supabaseURL.isEmpty {
      try visitor.visitSingularStringField(value: self.supabaseURL, fieldNumber: 2)
    }
    if !self.supabaseKey.isEmpty {
      try visitor.visitSingularStringField(value: self.supabaseKey, fieldNumber: 3)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  public static func ==(lhs: URLsList, rhs: URLsList) -> Bool {
    if lhs._versionTimestamp != rhs._versionTimestamp {return false}
    if lhs.supabaseURL != rhs.supabaseURL {return false}
    if lhs.supabaseKey != rhs.supabaseKey {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}
