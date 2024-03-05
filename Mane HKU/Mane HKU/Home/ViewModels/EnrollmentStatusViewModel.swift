//
//  EnrollmentStatusViewModel.swift
//  Mane HKU
//
//  Created by Yau Chin Pang on 28/2/2024.
//

import Foundation

@Observable final class EnrollmentStatusViewModel {
    @ObservationIgnored let defaults = UserDefaults.standard
    var successMessage: ToastMessage = ToastMessage()
    var errorMessage: ToastMessage = ToastMessage()
    var normalMessage: ToastMessage = ToastMessage()
    var loading = false
    var enrollmentStatus: EnrollmentStatusDisplay = EnrollmentStatusDisplay()
    
    init() {
        loading = true
        if let defaultEnrollmentStatus = defaults.data(forKey: UserDefaults.DefaultKey.enrollmentStatus.rawValue) {
            do {
                self.enrollmentStatus = try JSONDecoder().decode(EnrollmentStatusDisplay.self, from: defaultEnrollmentStatus)
                loading = false
                return
            } catch {
                print("Unable to decode user default transcript, need to retrieve new data again")
            }
        }
        print("retrieving new enrollment status....")
        Task(priority: .userInitiated) {
            await retrieveNewEnrollmentStatus()
        }
    }
    
    func retrieveNewEnrollmentStatus() async {
        defer {
            loading = false
        }
        if !PortalScraper.shared.isSignedIn {
            normalMessage.showMessage(title: "Still logging in....", subtitle: "Refresh later!")
            return
        }
        loading = true
        enrollmentStatus.enrollementStatusList = await PortalScraper.shared.getCourseEnrollmentStatus()
        if enrollmentStatus.enrollementStatusList == nil {
            errorMessage.showMessage(title: "Error Loading Status", subtitle: "Try again later")
            return
        }
        if let encoded = try? JSONEncoder().encode(enrollmentStatus) {
            defaults.setValue(encoded, forKey: UserDefaults.DefaultKey.enrollmentStatus.rawValue)
            print("saved to user default")
        }
    }
}
