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
    
    let semesterOrder: [Semester] = [.SUMMER, .SEM2, .SEM1]
    
    init() {
        Task {
            loading = true
            transcript = await PortalScraper.shared.getTranscript()
            if transcript == nil {
                errorMessage.showMessage(title: "Error Loading Transcript", subtitle: "Try again later")
            }
            loading = false
        }
    }
    
    func updateTranscript() async {
        loading = true
        transcript = await PortalScraper.shared.getTranscript()
        loading = false
    }
}
