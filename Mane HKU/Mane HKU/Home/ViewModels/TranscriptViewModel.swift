//
//  TranscriptViewModel.swift
//  Mane HKU
//
//  Created by Yau Chin Pang on 14/2/2024.
//

import Foundation

@Observable class TranscriptViewModel {
    var successMessage: ToastMessage = ToastMessage()
    var errorMessage: ToastMessage = ToastMessage()
    var loading = false
    var transcript: Transcript? {
        didSet {
            print(transcript)
        }
    }
    
    var courseSortedKeys: [String]? {
        get {
            if transcript == nil || transcript?.courseLists == nil {
                return nil
            } else {
                return Array(transcript!.courseLists!.keys).sorted().reversed()
            }
        }
    }
    
    init() {
        loading = true
        let defaults = UserDefaults.standard
        if let defaultTranscript = defaults.data(forKey: UserDefaults.DefaultKey.transcript.rawValue) {
            do {
                self.transcript = try JSONDecoder().decode(Transcript.self, from: defaultTranscript)
                loading = false
                return
            } catch {
                print("Unable to decode user default transcript, need to retrieve new data again")
            }
        }
        print("retrieving new transcript....")
        Task {
            transcript = await PortalScraper.shared.getTranscript()
            if transcript == nil {
                loading = false
                errorMessage.showMessage(title: "Error Loading Transcript", subtitle: "Try again later")
                return
            }
            loading = false
            if let encoded = try? JSONEncoder().encode(transcript) {
                defaults.setValue(encoded, forKey: UserDefaults.DefaultKey.transcript.rawValue)
                print("saved")
            }
            await upsertCourseCodes(with: transcript?.allCourses)
        }
    }
    
    func refreshTranscript() async {
        print("refreshing...")
        loading = true
        transcript = await PortalScraper.shared.getTranscript()
        loading = false
        Task {
            await upsertCourseCodes(with: transcript?.allCourses)
        }
    }
    
    func upsertCourseCodes(with courses: [String]?) async {
        guard let courses = courses else {
            return
        }
        if courses.isEmpty {
            return
        }
        print(courses)
        var request = Service_UpsertTakenCoursesRequest()
        request.takenCourseCodes = courses
        
        print("Calling service func to upsert")
        do {
            let callOptions = try await GRPCServiceManager.shared.getCallOptionsWithToken()
            print("recevied token")
            let unaryCall = GRPCServiceManager.shared.serviceClient.upsertTakenCourses(request, callOptions: callOptions)
            let statusCode = try await unaryCall.status.get()
            _ = try await unaryCall.response.get()
            print("received results, with status \(statusCode)")
        } catch {
            print(error.localizedDescription)
        }
    }
}
