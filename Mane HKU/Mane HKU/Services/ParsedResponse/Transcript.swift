//
//  Transcript.swift
//  Mane HKU
//
//  Created by Yau Chin Pang on 14/2/2024.
//

import Foundation

let semesterOrder: [Semester] = [.SUMMER, .SEM2, .SEM1]

struct Transcript: Codable {
    let program: String
//    let curriculum: [String]
    let year: UInt8
//    let majors: [String]?
//    let minors: [String]?
    
    var courseLists: [String: [Semester: [Course]]]?
    var allCourses: [String] {
        get {
            var output: [String] = []
            if let courseByYearly = courseLists?.values {
                for yearCourses in courseByYearly {
                    let courses = yearCourses.values.flatMap{
                        $0
                    } .map {
                        $0.code
                    }
                    output.append(contentsOf: courses)
                }
            }
            return output
        }
    }
    var ug5ePassed: Bool?
    var latestGPA: Double?
    var GPAs: [String: [Semester: GPAHistory]]?
}

enum Grade: String, Codable {
    case APlus = "A+"
    case A = "A"
    case AMin = "A-"
    case BPlus = "B+"
    case B = "B"
    case BMin = "B-"
    case CPlus = "C+"
    case C = "C"
    case CMin = "C-"
    case DPlus = "D+"
    case D = "D"
    case P = "P"
    case F = "F"
    case EX = "EX"
    case FL = "FL"
    case N = "N"
    case NC = "NC"
    case NE = "NE"
    case NS = "NS"
    case NV = "NV"
    case PE = "PE"
    case SC = "SC"
    case SE = "SE"
    case WD = "WD"
    case UNRELEASED = "**"
    case ONGOING = "ONGOING"
    case UNKNOWN = "UNKNOWN"
    
    var description : String {
        switch self {
        case .F:
            "Fail"
        case .EX:
            "Exemption granted"
        case .FL:
            "Not examined (Failed)"
        case .N:
            "Absence from examination due to illness"
        case .NC:
            "Did not complete"
        case .NE:
            "Not examined – NOT counted as Fail"
        case .NS:
            "Non-satisfactory completion"
        case .NV:
            "No evaluation – course continues in the following semester/year"
        case .PE:
            "Results not yet available"
        case .SC:
            "Satisfactory completion"
        case .SE:
            "Continuous assessment, result incorporated in summative assessment/examination"
        case .WD:
            "Withdrew from course/ module"
        case .ONGOING:
            "Ongoing"
        case .UNRELEASED:
            "To be released"
        case .P:
            "Passed"
        default:
            self.rawValue
        }
      }
}

enum CourseStatus: String, Codable {
    case toBeReleased, taken, transferred, inProgress, unknown
}

struct Course: Codable, Equatable {
    let code: String
    let title: String
    let term: String
    let semester: Semester
    let grade: Grade
    let credit: Double?
    let status: CourseStatus
    
    static func == (lCourse: Self, rCourse: Self) -> Bool {
        lCourse.code == rCourse.code
    }
}

enum Semester: Codable, Identifiable {
    var id: Self {
            return self
    }
    
    case SEM1, SEM2, SUMMER, UNKNOWN
    
    var description : String {
        switch self {
        case .SEM1:
            "Semester 1"
        case .SEM2:
            "Semester 2"
        case .SUMMER:
            "Summer Semester"
        case .UNKNOWN:
            "Unknown Semester"
        }
      }
}

struct GPAHistory: Codable {
    let term: String
    let semester: Semester
    let sGPA: Double
    let cGPA: Double
}
