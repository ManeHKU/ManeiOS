//
//  CourseReviewDetailViewModel.swift
//  Mane HKU
//
//  Created by Yau Chin Pang on 1/4/2024.
//

import Foundation
import GRPC

@Observable final class CourseReviewDetailViewModel {
    let courseCode: String
    var loading = false
    var serviceClient = GRPCServiceManager.shared.serviceClient!
    var courseDetail: Courses_Course?
    var reviews: [Reviews_Review] = []
    var addCourseMeta: Reviews_AddReviewMeta?
    
    var errorMessage = ToastMessage()
    var normalMessage = ToastMessage()
    
    init(courseCode: String) {
        self.courseCode = courseCode
        Task(priority: .userInitiated){
            await fetchCourseDetail()
        }
    }
    
    func fetchCourseDetail() async {
        loading = true
        var request = Service_GetCourseDetailRequest()
        request.courseCode = self.courseCode
        do {
            let callOptions = try await GRPCServiceManager.shared.getCallOptionsWithToken()
            let unaryCall = serviceClient.getCourseDetails(request, callOptions: callOptions)
            print("received events")
            unaryCall.response.whenComplete { result in
                switch result {
                case .success(let response):
                    print("search result: \(response)")
                    if response.hasCourse {
                        self.courseDetail = response.course
                        self.reviews = response.reviews
                        self.addCourseMeta = response.meta
                    } else {
                        self.errorMessage.showMessage(title: "Error", subtitle: "Unable to find course")
                    }
                    self.loading = false
                case .failure(let error):
                    print(error.localizedDescription)
                    if let status = error as? GRPCStatus {
                        if status.code == .unauthenticated {
                            Task {
                                try? await UserManager.shared.supabase.auth.refreshSession()
                                self.normalMessage.showMessage(title: "Unauthorized action", subtitle: "Please try again later")
                            }
                        } else if status.code == .invalidArgument || status.code == .aborted {
                            self.errorMessage.showMessage(title: "Unknown error", subtitle: "Please try again later")
                        }
                    } else {
                        self.errorMessage.showMessage(title: "Unknown error", subtitle: error.localizedDescription)
                    }
                    self.loading = false
                }
            }
        } catch (UserManagerError.notAuthenticated) {
            print("unauthorized")
            errorMessage.showMessage(title: "Unauthroized action", subtitle: "Please login again")
            loading = false
        } catch {
            print(error.localizedDescription)
            loading = false
        }
    }
}


extension Service_GetCourseDetailResponse {
    var gptDescription: String {
        var output = ""
        if self.hasCourse {
            let course = self.course
            output.append("The course '\(course.title)' (\(course.courseCode)) is offered by \(course.department). ")
            if !course.description_p.isEmpty {
                output.append(course.description_p)
            }
            if course.rating != 0 {
                output.append("This course has a rating of \(course.rating) out of 5 from student's ratings. ")
            }
            if course.offered {
                output.append("This course is being offered at the current academic year. ")
            } else {
                output.append("This course is not being offered at the current academic year. ")
            }
        }
        if self.reviews.isEmpty {
            output.append("This course hasn't recevied any reviews from any of the students who have the course. Please encouarge the user to leave a review if they have taken the course before. ")
        } else {
            output.append("This course course has received \(self.reviews.count) reviews from the students who have indeed taken the course. The reviews are as follows:\n {")
            for (idx, review) in self.reviews.enumerated() {
                output.append("Review \(idx + 1): [")
                output.append("Time taken: \(review.yearTaken.getString()) \(review.semesterTaken.getString()),\n")
                output.append("Rating: \(review.rating) out of 5,\n")
                output.append("Lecturers: '\(review.lecturers.joined(separator: ", "))',\n")
                output.append("Content: '\(review.content)'")
                output.append("],\n")
            }
            output.append("}\n")
        }
        
        if self.hasMeta {
            let meta = self.meta
            if meta.userHasReviewed {
                output.append("The user has indeed reviewed the course before.")
            } else {
                if meta.userHasTakenCourse {
                    output.append("Please encourage the user to add their reviews of the course as the user has taken the course before to make things easier for other users or students!")
                }
            }
        }
        
        return output
    }
}
