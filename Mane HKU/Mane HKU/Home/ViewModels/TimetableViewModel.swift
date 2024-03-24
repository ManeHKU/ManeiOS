//
//  TimetableViewModel.swift
//  Mane HKU
//
//  Created by Yau Chin Pang on 8/3/2024.
//

import Foundation

@Observable final class TimetableViewModel {
    @ObservationIgnored let defaults = UserDefaults.standard
    @ObservationIgnored let courseEventProvider = CourseEventProvider.shared
    var successMessage: ToastMessage = ToastMessage()
    var errorMessage: ToastMessage = ToastMessage()
    var normalMessage: ToastMessage = ToastMessage()
    var loading = false
    var events: [DateComponents: TimetableEvents]?
    
    init() {
        loading = true
        Task(priority: .userInitiated) {
            defer {
                loading = false
            }
            do {
                events = try await courseEventProvider.getEvents()
            } catch CourseTimetableError.FailToRetrieve {
                events = nil
                errorMessage.showMessage(title: "Error Loading Timetable", subtitle: "Try again later")
                return
            } catch CourseTimetableError.PortalNotSignedIn {
                PortalScraper.shared.resetSession()
                guard let portalId = KeychainManager.shared.secureGet(key: .PortalId) else {
                    print("Portal id doesn't exist")
                    errorMessage.showMessage(title: "Error Loading Timetable", subtitle: "Try again later")
                    return
                }
                let signedIn = await PortalScraper.shared.fastSISLogin(portalId: portalId, relogin: true)
                if signedIn {
                    events = try? await courseEventProvider.getEvents()
                    return
                } else {
                    print("relogin needed....")
                    errorMessage.showMessage(title: "Error Logging In", subtitle: "Please restart the app")
                    return
                }
            }
        }
    }
    
    func updateEvents() async {
        defer {
            loading = false
        }
        loading = true
        do {
            let newEvents = try await courseEventProvider.retrieveNewEvents()
            events = newEvents
        } catch CourseTimetableError.FailToRetrieve {
            events = nil
            errorMessage.showMessage(title: "Error Loading Timetable", subtitle: "Try again later")
            return
        } catch {
            print(error.localizedDescription)
            events = nil
            errorMessage.showMessage(title: "Unknown Error", subtitle: "Try again later")
            return
        }
        if events != nil {
            print("recevied events with \(events!.count)")
        }
    }
}
