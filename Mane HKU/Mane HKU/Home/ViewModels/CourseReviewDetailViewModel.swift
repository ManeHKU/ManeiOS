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
