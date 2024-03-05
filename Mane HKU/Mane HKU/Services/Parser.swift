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
        let gpaRows: Elements
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
            gpaRows = try doc.select("tr[id*='trGRID_GPA']")
        } catch {
            print(error)
            print("cannot parse transcript basic info")
            return nil
        }
        
        var courseLists = YearSemesterDictArray<Course>()
        if courseRows.count < 1 {
            print("unknown count as it got only \(courseRows.count) table row, stop parsing course grade rows")
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
        
        var gpaLists = YearSemesterDict<GPAHistory>()
        if gpaRows.count < 1 {
            print("unknown count as it got only \(courseRows.count) table row, stop parsing gpa rows")
        } else {
            for gpaRow in gpaRows {
                // 2019-20: { Sem1: [course1, 2, ...] }
                if let parsedGPARow = parseGPARow(tr: gpaRow) {
                    if gpaLists[parsedGPARow.term] != nil  {
                        gpaLists[parsedGPARow.term]![parsedGPARow.semester] = parsedGPARow
                    } else {
                        let currentTermSemester = [parsedGPARow.semester: parsedGPARow]
                        gpaLists[parsedGPARow.term] = currentTermSemester
                    }
                }
            }
            transcript.GPAs = gpaLists
            if let latestYear = gpaLists.keys.max() {
                for semester in semesterOrder {
                    if let semesterGPAs = gpaLists[latestYear]![semester] {
                        print("Got latest gpa in \(latestYear) \(semester)")
                        transcript.latestGPA = semesterGPAs.cGPA
                        break
                    }
                }
            } else {
                print("no keys in gpa list, ignoring gpa for now")
            }
        }
        
        if let nslCourseStatus = try? doc.getElementById("Z_TSC_CRDMD_WRK_DESCR254$0")?.text() {
            transcript.ug5ePassed = nslCourseStatus.contains("Passed")
        } else {
            transcript.ug5ePassed = false
        }
        
        return transcript
    }
    
    private func parseGPARow(tr row: Element) -> GPAHistory? {
        let tdCount = try? row.select("td").count
        if tdCount != 5 {
            print("This row only has \(String(describing: tdCount)) columns, returning nil")
            return nil
        }
        
        guard let rawSGPA = try? row.getElementsByAttributeValueStarting("id", "Z_TSC_CGPA_VW_Z_CUR_GPA_STR").first()?.text(trimAndNormaliseWhitespace: true)
            .filter({ !$0.isWhitespace }) else {
            print("Empty raw sGPA, returning nil")
            return nil
        }
        
        guard let rawCGPA = try? row.getElementsByAttributeValueStarting("id", "Z_TSC_CGPA_VW_Z_LS_GPA_STR").first()?.text(trimAndNormaliseWhitespace: true)
            .filter({ !$0.isWhitespace }) else {
            print("Empty raw cGPA, returning nil")
            return nil
        }
        
        guard let sGPA = Double(rawSGPA), let cGPA = Double(rawCGPA) else {
            print("ignoring this row as one of the gpa are empty")
            return nil
        }
        
        guard let rawTerm = try? row.getElementsByAttributeValueStarting("id", "TERM_TBL_DESCR").first()?.text(trimAndNormaliseWhitespace: true) else {
            print("Empty raw term, returning nil")
            return nil
        }
        
        guard let parsedSemesterTerm = parseRawTermSemester(input: rawTerm) else {
            print("cannot parse term/semester")
            return nil
        }
        print("parsed \(parsedSemesterTerm.0) \(parsedSemesterTerm.1)")
        
        return GPAHistory(term: parsedSemesterTerm.term, semester: parsedSemesterTerm.semester, sGPA: sGPA, cGPA: cGPA)
    }
    
    private func parseRawTermSemester(input rawTerm: String) -> (term: String, semester: Semester)? {
        let rawTermSplit = rawTerm.components(separatedBy: " ")
        print("term: \(String(describing: rawTerm))")
        if rawTermSplit.count != 3 {
            print("unknown term detected")
            return nil
        }
        let term = rawTermSplit[0]
        let semester: Semester
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
        
        return (term, semester)
    }
    
    private func parseTranscriptCourseRow(tr row: Element) -> Course? {
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
        
        guard let parsedSemesterTerm = parseRawTermSemester(input: rawTerm) else {
            print("cannot parse term/semester")
            return nil
        }
        
        let rawGrade = try? row.getElementsByAttributeValueStarting("id","CRSE_GRADE").first()?.text(trimAndNormaliseWhitespace: true)
        let grade: Grade
        if let unwrappedRawGrade = rawGrade {
            print("grade: \(unwrappedRawGrade)")
            if unwrappedRawGrade.isEmpty || unwrappedRawGrade == " " {
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
        
        let course = Course(code: code, title: title, term: parsedSemesterTerm.term, semester: parsedSemesterTerm.semester, grade: grade, credit: credit, status: status)
        
        return course
    }
    
    func parseEnrollmentStatus(html: String) -> SemesterDictArray<CourseInEnrollmentStatus>? {
        defer {
            print("ended parsing enrollment status")
        }
        print("parsing enrollment status from html")
        let doc: Document
        do {
            doc = try SwiftSoup.parse(html)
        } catch {
            print(error)
            print("cannot parse html file")
            return nil
        }
        var outputDict = SemesterDictArray<CourseInEnrollmentStatus>()
        var years: Set<String> = []
        let enrollmentStatusRows: Elements
        do {
            enrollmentStatusRows = try doc.select("tr[id*='trZ_CRSE_APR_VW']")
            for row in enrollmentStatusRows {
                if let parsedCourseEnrollStatus = parseCourseInEnrollmentStatus(tr: row) {
                    if years.isEmpty {
                        years.insert(parsedCourseEnrollStatus.term)
                    } else if !years.contains(parsedCourseEnrollStatus.term) {
                        print("unknown term. there should be only 1 term!!")
                        return nil
                    }
                    outputDict[parsedCourseEnrollStatus.semester, default: []].append(parsedCourseEnrollStatus)
                }
            }
        } catch {
            print(error)
            print("cannot parse enrollment status table")
            return nil
        }
        
        return outputDict
    }
    
    private func parseCourseInEnrollmentStatus(tr row: Element) -> CourseInEnrollmentStatus? {
        let tdCount = try? row.select("td").count
        if tdCount != 6 {
            print("This row only has \(String(describing: tdCount)) columns, returning nil")
            return nil
        }
        
        guard let rawTerm = try? row.getElementsByAttributeValueStarting("id", "TERM_TBL_DESCR").first()?.text(trimAndNormaliseWhitespace: true) else {
            print("Empty raw term, returning nil")
            return nil
        }
        
        guard let parsedSemesterTerm = parseRawTermSemester(input: rawTerm) else {
            print("cannot parse term/semester")
            return nil
        }
        print("parsed \(parsedSemesterTerm.term) \(parsedSemesterTerm.semester)")
        
        guard let rawCourseDescription = try? row.getElementsByAttributeValueStarting("id", "Z_CRSE_APR_VW_DESCR254").first()?.text(trimAndNormaliseWhitespace: true) else {
            print("Empty raw course description, returning nil")
            return nil
        }
        
        guard let courseCodeRegex = try? NSRegularExpression(pattern: "(?<rawCode>[A-Z]{4} \\d{4}(?:FY)?)-(?<subclass>[1-3SF]A)") else {
            print("cannot compile regex, should not happen")
            return nil
        }
        
        var code: String? = nil
        var subclass: String? = nil
        guard let matches = courseCodeRegex
            .matches(in: rawCourseDescription, range: NSRange(rawCourseDescription.startIndex..., in: rawCourseDescription)).first else {
                print("cannot retrieve code with regex, returning nil")
                return nil
            }
        
        let codeMatchRange = matches.range(withName: "rawCode"), subclassMatchRange = matches.range(withName: "subclass")
        // Extract the substring matching the named capture group
        if let codeRange = Range(codeMatchRange, in: rawCourseDescription), let subclassRange = Range(subclassMatchRange, in: rawCourseDescription) {
            let codeCapture = String(rawCourseDescription[codeRange]), subclassCapture = String(rawCourseDescription[subclassRange])
            code = codeCapture.filter {
                !$0.isWhitespace
            }
            subclass = subclassCapture
        }
        if code == nil || subclass == nil {
            print("failed to extract code or subclass", code, subclass)
            return nil
        }
        print(code, subclass)
        
        guard let rawStatus = try? row.getElementsByAttributeValueStarting("id", "Z_CRSE_APR_VW_Z_ACTION").first()?.text(trimAndNormaliseWhitespace: true) else {
            print("Empty raw status, returning nil")
            return nil
        }
        let enrollmentStatus = CourseEnrollmentStatus(rawValue: rawStatus) ?? .unknown
        
        guard let schedule = try? row.getElementsByAttributeValueStarting("id", "Z_CRSE_APR_VW_DESCR200").first()?.text(trimAndNormaliseWhitespace: false) else {
            print("Empty raw schedule, returning nil")
            return nil
        }
        
        return CourseInEnrollmentStatus(term: parsedSemesterTerm.term, semester: parsedSemesterTerm.semester, code: code!, subclass: subclass!, status: enrollmentStatus, schedule: schedule)
    }
}
