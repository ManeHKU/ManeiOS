//
//  CourseReviewListViewModels.swift
//  Mane HKU
//
//  Created by Yau Chin Pang on 31/3/2024.
//

import Foundation
import GRPC

@Observable final class CourseReviewListViewModel {
    var coursesDisplayed: [Courses_Course] = []
    var moreResults = false
    var loading = false
    var serviceClient = GRPCServiceManager.shared.serviceClient!
    var pageSize: Int32 = 20
    var errorMessage = ToastMessage()
    var normalMessage = ToastMessage()
    
    init() {
        Task {
            await defaultListCourses()
        }
    }
    
    func defaultListCourses() async {
        await listCourses(pageSize: 100, lastCode: nil)
    }
    
    func listCourses(pageSize requestPageSize: Int32? , lastCode: String?) async {
        print("running list course with \(lastCode) as last course code")
        var request = Service_ListCoursesRequest()
        if requestPageSize != nil {
            request.pageSize = requestPageSize!
        } else {
            request.pageSize = self.pageSize
        }
        if lastCode != nil {request.lastCode = lastCode!}
        do {
            loading = true
            let callOptions = try await GRPCServiceManager.shared.getCallOptionsWithToken()
            let unaryCall = serviceClient.listCourses(request, callOptions: callOptions)
            print("received events")
            unaryCall.response.whenComplete { result in
                switch result {
                case .success(let response):
                    if response.courses.isEmpty {
                        if lastCode == nil {
                            self.normalMessage.showMessage(title: "No courses found", subtitle: "Please try again later")
                        }
                    } else {
                        if lastCode == nil {
                            self.coursesDisplayed = response.courses
                        } else {
                            self.coursesDisplayed.append(contentsOf: response.courses)
                        }
                    }
                    self.moreResults = response.moreResults
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
                }
                self.loading = false
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
    
    func searchCourses(query: String, lastCode: String?) async {
        print("running search course with \(lastCode) as last course code and \(query) as query")
        var request = Service_SearchCourseRequest()
        request.pageSize = self.pageSize
        request.query = query
        if lastCode != nil {request.lastCode = lastCode!}
        do {
            loading = true
            let callOptions = try await GRPCServiceManager.shared.getCallOptionsWithToken()
            let unaryCall = serviceClient.searchCourses(request, callOptions: callOptions)
            print("received events")
            unaryCall.response.whenComplete { result in
                switch result {
                case .success(let response):
                    print("search result: \(response)")
                    if response.courses.isEmpty {
                        if lastCode == nil {
                            self.normalMessage.showMessage(title: "No courses found", subtitle: "Please try again later")
                        }
                    } else {
                        if lastCode == nil {
                            self.coursesDisplayed = response.courses
                        } else {
                            self.coursesDisplayed.append(contentsOf: response.courses)
                        }
                    }
                    self.moreResults = response.moreResults
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
                }
                self.loading = false
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
