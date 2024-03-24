//
//  TranscriptViewModel.swift
//  Mane HKU
//
//  Created by Yau Chin Pang on 14/2/2024.
//

import Foundation

@Observable final class TranscriptViewModel {
    @ObservationIgnored private var defaults = UserDefaults.standard
    var successMessage: ToastMessage = ToastMessage()
    var errorMessage: ToastMessage = ToastMessage()
    var normalMessage: ToastMessage = ToastMessage()
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
            await refreshTranscript()
        }
    }
    
    func refreshTranscript() async {
        if !PortalScraper.shared.isSignedIn {
            normalMessage.showMessage(title: "Still logging in....", subtitle: "Refresh later!")
            return
        }
        print("Start refreshing")
        loading = true
        transcript = await PortalScraper.shared.getTranscript()
        loading = false
        if let encoded = try? JSONEncoder().encode(transcript) {
            defaults.setValue(encoded, forKey: UserDefaults.DefaultKey.transcript.rawValue)
            print("saved")
        }
        Task {
            await upsertCourseCodes(with: transcript?.takenOrPassedCourses)
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
