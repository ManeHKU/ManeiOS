//
//  AddEventViewModel.swift
//  Mane HKU
//
//  Created by Yau Chin Pang on 11/4/2024.
//

import Foundation
import UIKit
import SwiftUI
import PhotosUI
import SwiftProtobuf
import GRPC

enum ImageState {
    case retrieving(Progress), success(Data), failure(Error?)
}

@Observable class AddEventViewModel {
    @ObservationIgnored private var supabase = UserManager.shared
    var loading = false
    var pickedOrganization: String {
        didSet {
            print(pickedOrganization)
        }
    }
    var title = ""
    var startDate: Date = Date.now {
        didSet {
            endDate = startDate.addingTimeInterval(60 * 60)
        }
    }
    var endDate: Date = Date.now.addingTimeInterval(60 * 60)
    var location = ""
    var participationLimt: Int = 2
    
    var errorAlert = ToastMessage()
    var errorMessage = ToastMessage()
    
    init(firstOrganizationId: String) {
        pickedOrganization = firstOrganizationId
    }
    
    var photoItem: PhotosPickerItem? {
        didSet {
            if let photoItem {
                displayImage = nil
                imageState = nil
                let progress = loadTransferable(from: photoItem)
                imageState = .retrieving(progress)
            }
        }
    }
    var imageState: ImageState? {
        didSet {
            switch imageState {
            case .failure(let error):
                errorAlert.showMessage(title: "Fail to load image", subtitle: nil)
                print(error?.localizedDescription ?? "no error")
                photoItem = nil
            default:
                return
            }
        }
    }
    var displayImage: Image?
    
    var description = ""
    
    var applyInfo = ""
    
    var numOfQuestions = 0
    var questions = [String](repeating: "", count: 5)
    
    var questionsValid: Bool {
        get {
            if numOfQuestions == 0 {
                return true
            }
            return questions[0...(_numOfQuestions - 1)].allSatisfy {
                !$0.isEmpty
            }
        }
    }
    
    var validForm: Bool {
        get {
            !title.isEmpty && startDate > Date.now && endDate > startDate && !location.isEmpty && !description.isEmpty && questionsValid
        }
    }
    
    var addEventResult: Bool?
    
    private func loadTransferable(from imageSelection: PhotosPickerItem) -> Progress {
        return imageSelection.loadTransferable(type: Data.self) { result in
            DispatchQueue.main.async {
                guard self.photoItem == self.photoItem else {
                    print("Failed to get the selected item.")
                    return
                }
                switch result {
                case .success(let data?):
                    print("got data")
                    let uiImage = UIImage(data: data)
                    if let uiImage {
                        self.imageState = .success(data)
                        self.displayImage = Image(uiImage: uiImage)
                    } else {
                        self.imageState = .failure(nil)
                    }
                case .success(nil):
                    self.imageState = .failure(nil)
                case .failure(let error):
                    self.imageState = .failure(error)
                }
            }
        }
    }
    
    func addEvent() async {
        loading = true
        var imageKey: String?
        switch imageState {
        case .success(let data):
            print("uploading to supabase s3")
            guard let fileType = photoItem?.supportedContentTypes.first?.preferredMIMEType else {
                loading = false
                errorAlert.showMessage(title: "Image not supported!", subtitle: nil)
                return
            }
            do {
                let uuid = UUID().uuidString
                imageKey = try await UserManager.shared.addEventImage(from: uuid, data: data, fileType: fileType)
            } catch (AddImageError.itemIDError) {
                loading = false
                errorAlert.showMessage(title: "Item ID Incorrect", subtitle: nil)
                return
            } catch (AddImageError.failedToUpload(let err)) {
                loading = false
                errorAlert.showMessage(title: err.localizedCapitalized, subtitle: nil)
                return
            } catch {
                loading = false
                errorAlert.showMessage(title: error.localizedDescription, subtitle: nil)
                return
            }
        case .failure(_), .retrieving(_):
            loading = false
            errorAlert.showMessage(title: "Image not loaded!", subtitle: nil)
            return
        case .none:
            if photoItem != nil {
                loading = false
                errorAlert.showMessage(title: "Unknown Image Error!", subtitle: nil)
                return
            }
        }
        var request = Events_AddEventRequest()
        request.organizerID = pickedOrganization
        request.title = title
        if let imageKey {
            request.imagePath = imageKey
        }
        request.startTime = Google_Protobuf_Timestamp(date: startDate)
        request.endTime = Google_Protobuf_Timestamp(date: endDate)
        request.location = location
        request.description_p = description
        request.participantLimit = Int32(participationLimt)
        
        if !(applyInfo.isEmpty && numOfQuestions == 0) {
            var requestApplyInfo = Events_ApplyInfo()
            if !applyInfo.isEmpty {
                requestApplyInfo.info = applyInfo
            }
            if numOfQuestions > 0 && questionsValid {
                requestApplyInfo.questions = Array(questions[0...(_numOfQuestions - 1)])
            }
            request.applyInfo = requestApplyInfo
        }
        
        do {
            let callOptions = try await GRPCServiceManager.shared.getCallOptionsWithToken()
            let unaryCall = GRPCServiceManager.shared.serviceClient.addEvent(request, callOptions: callOptions)
            unaryCall.response.whenComplete { result in
                print("received user organizations admin")
                switch result {
                case .success(let response):
                    if response.hasErrorMessage {
                        self.errorAlert.showMessage(title: response.errorMessage.capitalized, subtitle: nil)
                    }else {
                        self.loading = false
                        self.addEventResult = response.success
                        return
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                    if let status = error as? GRPCStatus {
                        if status.code == .unauthenticated {
                            Task {
                                _ = try? await UserManager.shared.supabase.auth.refreshSession()
                                self.errorMessage.showMessage(title: "Unauthorized action", subtitle: "Please try again later")
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
            loading = false
            errorMessage.showMessage(title: "Unauthroized action", subtitle: "Please login again")
        } catch {
            print(error.localizedDescription)
            loading = false
        }
    
    }
}
