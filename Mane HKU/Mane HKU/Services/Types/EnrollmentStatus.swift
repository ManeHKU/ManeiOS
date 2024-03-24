//
//  EnrollmentStatus.swift
//  Mane HKU
//
//  Created by Yau Chin Pang on 28/2/2024.
//

import Foundation
import SwiftUI

enum CourseEnrollmentStatus: String, Codable {
    case notApproved = "Not Approved"
    case dropped = "Dropped"
    case approved = "Approved"
    case unknown
    
    var iconImage: some View {
        switch self {
        case .approved:
            return Image(systemName: "checkmark.circle.fill").foregroundStyle(.accent)
        case .notApproved:
            return Image(systemName: "xmark.circle.fill").foregroundStyle(.red)
        case .dropped:
            return Image(systemName: "slash.circle.fill").foregroundStyle(.yellow)
        case .unknown:
            return Image(systemName: "questionmark.circle.fill").foregroundStyle(.yellow)
        }
    }
}

struct CourseInEnrollmentStatus: Codable {
    let term: String
    let semester: Semester
    let code: String
    let subclass: String
    let status: CourseEnrollmentStatus
    let schedule: String
}

struct EnrollmentStatusDisplay: Codable {
    var enrollementStatusList: SemesterDictArray<CourseInEnrollmentStatus>? {
        didSet {
            if enrollementStatusList != nil {
                lastUpdatedTime = Date.now
            }
        }
    }
    private(set) var lastUpdatedTime: Date?
    
    init(enrollmentStatusList: SemesterDictArray<CourseInEnrollmentStatus>) {
        self.enrollementStatusList = enrollmentStatusList
        self.lastUpdatedTime = Date.now
    }
    
    init() {
        self.enrollementStatusList = nil
        self.lastUpdatedTime = nil
    }
}
