// DO NOT EDIT.
// swift-format-ignore-file
//
// Generated by the Swift generator plugin for the protocol buffer compiler.
// Source: courses.proto
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

public struct Courses_Course {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  public var courseCode: String = String()

  public var title: String = String()

  public var department: String = String()

  public var description_p: String = String()

  public var rating: Float = 0

  public var offered: Bool = false

  public var unknownFields = SwiftProtobuf.UnknownStorage()

  public init() {}
}

#if swift(>=5.5) && canImport(_Concurrency)
extension Courses_Course: @unchecked Sendable {}
#endif  // swift(>=5.5) && canImport(_Concurrency)

// MARK: - Code below here is support for the SwiftProtobuf runtime.

fileprivate let _protobuf_package = "courses"

extension Courses_Course: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = _protobuf_package + ".Course"
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .standard(proto: "course_code"),
    2: .same(proto: "title"),
    3: .same(proto: "department"),
    4: .same(proto: "description"),
    5: .same(proto: "rating"),
    6: .same(proto: "offered"),
  ]

  public mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularStringField(value: &self.courseCode) }()
      case 2: try { try decoder.decodeSingularStringField(value: &self.title) }()
      case 3: try { try decoder.decodeSingularStringField(value: &self.department) }()
      case 4: try { try decoder.decodeSingularStringField(value: &self.description_p) }()
      case 5: try { try decoder.decodeSingularFloatField(value: &self.rating) }()
      case 6: try { try decoder.decodeSingularBoolField(value: &self.offered) }()
      default: break
      }
    }
  }

  public func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if !self.courseCode.isEmpty {
      try visitor.visitSingularStringField(value: self.courseCode, fieldNumber: 1)
    }
    if !self.title.isEmpty {
      try visitor.visitSingularStringField(value: self.title, fieldNumber: 2)
    }
    if !self.department.isEmpty {
      try visitor.visitSingularStringField(value: self.department, fieldNumber: 3)
    }
    if !self.description_p.isEmpty {
      try visitor.visitSingularStringField(value: self.description_p, fieldNumber: 4)
    }
    if self.rating != 0 {
      try visitor.visitSingularFloatField(value: self.rating, fieldNumber: 5)
    }
    if self.offered != false {
      try visitor.visitSingularBoolField(value: self.offered, fieldNumber: 6)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  public static func ==(lhs: Courses_Course, rhs: Courses_Course) -> Bool {
    if lhs.courseCode != rhs.courseCode {return false}
    if lhs.title != rhs.title {return false}
    if lhs.department != rhs.department {return false}
    if lhs.description_p != rhs.description_p {return false}
    if lhs.rating != rhs.rating {return false}
    if lhs.offered != rhs.offered {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}