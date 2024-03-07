//
//  TimetableViewModel.swift
//  Mane HKU
//
//  Created by Yau Chin Pang on 8/3/2024.
//

import Foundation

@Observable final class TimetableViewModel {
    @ObservationIgnored let defaults = UserDefaults.standard
    var successMessage: ToastMessage = ToastMessage()
    var errorMessage: ToastMessage = ToastMessage()
    var normalMessage: ToastMessage = ToastMessage()
    var loading = false
    var timetableEvents: TimetableEvents = []
    
    init() {
        loading = true
        if let defaultTimetable = defaults.data(forKey: UserDefaults.DefaultKey.timetable.rawValue) {
            do {
                self.timetableEvents = try JSONDecoder().decode(TimetableEvents.self, from: defaultTimetable)
                loading = false
                return
            } catch {
                print("Unable to decode user default timetable, need to retrieve new data again")
            }
        }
        print("retrieving new timetable....")
        Task(priority: .userInitiated) {
            await retrieveNewTimetable()
        }
    }
    
    func retrieveNewTimetable() async {
        defer {
            loading = false
        }
        if !PortalScraper.shared.isSignedIn {
            normalMessage.showMessage(title: "Still logging in....", subtitle: "Refresh later!")
            return
        }
        loading = true
        timetableEvents = await PortalScraper.shared.getEventList()
        print("received event list with len: \(timetableEvents.count)")
        if timetableEvents.isEmpty {
            errorMessage.showMessage(title: "Error Loading Timetable", subtitle: "Try again later")
            return
        }
        if let encoded = try? JSONEncoder().encode(timetableEvents) {
            defaults.setValue(encoded, forKey: UserDefaults.DefaultKey.timetable.rawValue)
            print("saved to user default")
        }
    }
}
