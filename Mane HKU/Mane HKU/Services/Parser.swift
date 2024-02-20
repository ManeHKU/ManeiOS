//
//  Parser.swift
//  Mane HKU
//
//  Created by Yau Chin Pang on 25/1/2024.
//

import Foundation
import SwiftSoup

struct Parser {
    func parseInfo(html: String) -> UserInfo? {
        print("parsing user info from html")
        do {
            let uid: UInt
            let doc = try SwiftSoup.parse(html)
            
            let uidString = try doc.getElementById("Z_SS_STUD_SRCH_EMPLID")?.text(trimAndNormaliseWhitespace: true)
            if let unwrappedUidString = uidString {
                uid = UInt(unwrappedUidString) ?? 0
            } else {
                uid = 0
            }
            
            let name = try doc.getElementById("PERSONAL_DATA_NAME")?.text(trimAndNormaliseWhitespace: true) ?? ""
            
            let userInfo = UserInfo(uid: uid, fullName: name)
            print("parsed user info successfully")
            return userInfo
        } catch {
            print(error)
            print("aborting parse user info function")
            return nil
        }
    }
    
    func parseTranscript(html: String) -> Transcript? {
        defer {
            print("ended parsing transcript")
        }
        print("parsing transcript from html")
        let doc: Document
        do {
            doc = try SwiftSoup.parse(html)
        } catch {
            print(error)
            print("cannot parse html file")
            return nil
        }
        var transcript: Transcript
        let courseRows: Elements
        do {
            let program: String = try doc.getElementById("Z_HKU_ACAD_PROG_Z_ACAD_PROG_TITLE")?.text(trimAndNormaliseWhitespace: true) ?? ""
            
            let yearHTML = try doc.getElementById("LEVEL_PROJ_DESCR")?.text(trimAndNormaliseWhitespace: true) ?? ""
            var year: UInt8 = 0
            if yearHTML != "" && yearHTML.starts(with: "Year") {
                let splitYear = yearHTML.split(separator: " ")
                year = UInt8(splitYear[1]) ?? 0
            }
            transcript = Transcript(program: program, year: year)
            courseRows = try doc.select("table[id*='CRSE_HIST$scroll'] tbody tr")
        } catch {
            print(error)
            print("cannot parse transcript basic info")
            return nil
        }
        
        var courseLists = [String: [Semester: [Course]]]()
        if courseRows.count < 1 {
            print("unknown count as it got only \(courseRows.count) table row, stop parsin g")
        } else {
            for courseRow in courseRows.dropFirst() {
                let parsedCourse = parseTranscriptCourseRow(tr: courseRow)
                // 2019-20: { Sem1: [course1, 2, ...] }
                if let unwrappedCourse = parsedCourse {
                    if courseLists[unwrappedCourse.term] != nil  {
                        courseLists[unwrappedCourse.term]![unwrappedCourse.semester, default: []].append(unwrappedCourse)
                    } else {
                        let currentTermSemester = [unwrappedCourse.semester: [unwrappedCourse]]
                        courseLists[unwrappedCourse.term] = currentTermSemester
                    }
                }
            }
            transcript.courseLists = courseLists
        }
        
        if let nslCourseStatus = try? doc.getElementById("Z_TSC_CRDMD_WRK_DESCR254$0")?.text() {
            transcript.ug5ePassed = nslCourseStatus.contains("Passed")
        } else {
            transcript.ug5ePassed = false
        }
        
        return transcript
    }
    
    func parseTranscriptCourseRow(tr row: Element) -> Course? {
        let tdCount = try? row.select("td").count 
        if tdCount != 7 {
            print("This row only has \(String(describing: tdCount)) columns, returning nil")
            return nil
        }
        
        guard let code = try? row.getElementsByAttributeValueStarting("id", "CRSE_NAME").first()?.text(trimAndNormaliseWhitespace: true)
            .filter({ !$0.isWhitespace }) else {
            print("Empty course code, returning nil")
            return nil
        }
        
        print("processing \(String(describing: code))")
        
        
        guard let title = try? row.getElementsByAttributeValueStarting("id","CRSE_DESCR").first()?.text(trimAndNormaliseWhitespace: true) else {
            print("Empty course title, returning nil")
            return nil
        }
        
        guard let rawTerm = try? row.getElementsByAttributeValueStarting("id","TERM_TBL_DESCR").first()?.text(trimAndNormaliseWhitespace: true) else {
            print("Empty raw term, returning nil")
            return nil
        }
        print("raw term: \(rawTerm)")
        
        let term: String
        let semester: Semester
        let rawTermSplit = rawTerm.components(separatedBy: " ")
        print("term: \(String(describing: rawTerm))")
        if rawTermSplit.count != 3 {
            print("unknown term detected")
            return nil
        }
        term = rawTermSplit[0]
        switch rawTermSplit.last {
        case "1":
            semester = .SEM1
        case "2":
            semester = .SEM2
        default:
            if rawTermSplit[1] == "Sum" && rawTermSplit.last == "Sem" {
                semester = .SUMMER
            } else {
                print("UNKNOWN: \(rawTermSplit[-1])")
                semester = .UNKNOWN
            }
        }
        
        let rawGrade = try? row.getElementsByAttributeValueStarting("id","CRSE_GRADE").first()?.text(trimAndNormaliseWhitespace: true)
        let grade: Grade
        if let unwrappedRawGrade = rawGrade {
            print("grade: \(unwrappedRawGrade)")
            if unwrappedRawGrade == " " {
                grade = .ONGOING
            } else {
                grade = Grade(rawValue: unwrappedRawGrade) ?? .UNKNOWN
            }
        } else {
            grade = .UNKNOWN
        }
        
        var credit: Double? = nil
        if let rawCredit = try? row.getElementsByAttributeValueStarting("id","CRSE_UNITS").first()?.text(trimAndNormaliseWhitespace: true) {
            credit = Double(rawCredit)
        }
        
        
        var status: CourseStatus = .unknown
        if let statusImgs = try? row.select("img[src]") {
            if statusImgs.count != 1 {
                print("more than 1 img src. impossible")
            } else {
                let statusSrc = try? statusImgs.first()?.attr("src")
                if statusSrc == nil {
                    status = .unknown
                } else if grade == .UNRELEASED {
                    status = .toBeReleased
                } else if statusSrc!.contains("TAKEN") {
                    status = .taken
                } else if statusSrc!.contains("ENROLLED") {
                    status = .inProgress
                }
            }
        }
        
        let course = Course(code: code, title: title, term: term, semester: semester, grade: grade, credit: credit, status: status)
        
        return course
    }
}
