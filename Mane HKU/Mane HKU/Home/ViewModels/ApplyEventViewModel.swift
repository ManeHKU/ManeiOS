//
//  ApplyEventViewModel.swift
//  Mane HKU
//
//  Created by Yau Chin Pang on 11/4/2024.
//

import Foundation
import GRPC

@Observable class ApplyEventViewModel {
    @ObservationIgnored let applyInfo: Events_ApplyInfo
    @ObservationIgnored let eventID: String
    var loading = false
    
    var hasReadInfo = false
    var answers: [String]
    
    var errorMessage = ToastMessage()
    
    var validForm: Bool {
        get {
            let allAnswersNotEmpty = answers.allSatisfy {
                !$0.isEmpty
            }
            if applyInfo.hasInfo {
                return hasReadInfo && allAnswersNotEmpty
            }
            return allAnswersNotEmpty
        }
    }
    
    var appliedEvent = false
    
    init(applyInfo: Events_ApplyInfo, eventID: String) {
        self.applyInfo = applyInfo
        self.eventID = eventID
        self.answers = [String](repeating: "", count: applyInfo.questions.count)
    }
    
    func applyEvent() async {
        print("applying event")
        var request = Events_ApplyEventRequest()
        request.eventID = eventID
        var questionAnswer = [String:String]()
        for i in applyInfo.questions.indices {
            questionAnswer[applyInfo.questions[i]] = answers[i]
        }
        request.answers = questionAnswer
        do {
            loading = true
            let callOptions = try await GRPCServiceManager.shared.getCallOptionsWithToken()
            let unaryCall = GRPCServiceManager.shared.serviceClient.applyEvent(request, callOptions: callOptions)
            unaryCall.response.whenComplete { result in
                print("received apply event resp")
                switch result {
                case .success(let response):
                    print(response)
                    if response.hasErrorMessage && !response.success {
                        self.errorMessage.showMessage(title: "Error!", subtitle: response.errorMessage.capitalized)
                    } else if response.success {
                        self.appliedEvent = true
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                    if let status = error as? GRPCStatus {
                        if status.code == .unauthenticated {
                            Task {
                                try? await UserManager.shared.supabase.auth.refreshSession()
                                self.errorMessage.showMessage(title: "Unauthorized action", subtitle: "Please try again")
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
