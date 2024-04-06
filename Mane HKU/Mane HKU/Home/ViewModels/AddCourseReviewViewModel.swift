//
//  AddCourseReviewViewModel.swift
//  Mane HKU
//
//  Created by Yau Chin Pang on 4/4/2024.
//

import Foundation
import GRPC

@Observable final class AddCourseReviewViewModel {
    let courseCode: String
    var loading = false
    var serviceClient = GRPCServiceManager.shared.serviceClient!
    
    var errorForm = ""
    var lecturerError = ""
    var reviewError = ""
    var timeError = ""
    var reviewAdded = false
    
    var selectedSemester: Reviews_Semester = .sem1
    var selectedYear: Reviews_AcademicYear = .ay20232024
    
    var content: String = ""
    var numOfLecturers = 0
    var lecturers = [String](repeating: "", count: 5)
    
    var rating = 3
    
    var validForm: Bool {
        get {
            if content.count < 10 {
                return false
            }
            var allLecturersValid = true
            for i in 0..<(numOfLecturers + 1) {
                let lecturer = lecturers[i]
                if lecturer.count < 5 {
                    allLecturersValid = false
                    break
                }
            }
            if !allLecturersValid {
                return false
            }
            if !(1...5 ~= rating) {
                return false
            }
            return true
        }
    }
    
    init(courseCode: String) {
        self.courseCode = courseCode
    }
    
    func resetToDefault() {
        selectedSemester = .sem1
        selectedYear = .ay20232024
        
        content = ""
        lecturers = [String](repeating: "", count: 5)
        
        rating = 3
    }
    
    func submitAddReview() async {
        loading = true
        var request = Reviews_AddReviewRequest()
        request.courseCode = self.courseCode
        request.yearTaken = self.selectedYear
        request.semesterTaken = self.selectedSemester
        request.content = self.content
        guard 0...4 ~= numOfLecturers else {
            print("num of lectureres in incorrect range")
            errorForm = "Please select the correct range."
            return
        }
        request.lecturers = Array(self.lecturers[0...numOfLecturers])
        guard 1...5 ~= rating else {
            print("invalid range for rating")
            errorForm = "The rating score should only be 1 to 5."
            return
        }
        request.rating = Int32(self.rating)
        do {
            let callOptions = try await GRPCServiceManager.shared.getCallOptionsWithToken()
            let unaryCall = serviceClient.addReview(request, callOptions: callOptions)
            print("received add course event resp")
            unaryCall.response.whenComplete { result in
                switch result {
                case .success(let response):
                    print("add course result: \(response)")
                    switch response.result {
                    case .success:
                        print("whoooo")
                        self.reviewAdded = true
                    case .invalidYearTaken, .invalidSemesterTaken:
                        self.timeError = response.errorMessage
                    case .invalidRating, .invalidContent:
                        self.lecturerError = response.errorMessage
                    case .invalidLecturers:
                        self.lecturerError = response.errorMessage
                    case .errorAlreadyReviewed, .errorUserNotTakenCourse, .invalidCourseCode:
                        self.errorForm = response.errorMessage
                    case .UNRECOGNIZED(let i):
                        self.errorForm = "Unknown error: \(i)"
                    }
                    self.loading = false
                case .failure(let error):
                    print(error.localizedDescription)
                    if let status = error as? GRPCStatus {
                        if status.code == .unauthenticated {
                            Task {
                                try? await UserManager.shared.supabase.auth.refreshSession()
                                self.errorForm = "Unknown error. Please try again"
                            }
                        } else if status.code == .invalidArgument || status.code == .aborted {
                            self.errorForm = "Unknown error. Please try again later."
                        }
                    } else {
                        self.errorForm = "Unknown error. \(error.localizedDescription)"
                    }
                    self.loading = false
                }
            }
        } catch (UserManagerError.notAuthenticated) {
            print("unauthorized")
            self.errorForm = "Unknown error. Please try again later."
            loading = false
        } catch {
            print(error.localizedDescription)
            self.errorForm = "Unknown error. Please try again later."
            loading = false
        }
    }
    
    func resetAllError() {
        errorForm = ""
        lecturerError = ""
        reviewError = ""
        timeError = ""
    }
}
