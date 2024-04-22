//
//  CourseNotificationManager.swift
//  Mane HKU
//
//  Created by Yau Chin Pang on 21/3/2024.
//

import Foundation
import UserNotifications

@Observable
final class CourseNotificationManager {
//    private var notifications: [LocalNotification]'
    let coursEventProvider = CourseEventProvider.shared
    var authorizationStatus: UNAuthorizationStatus? = nil
    let coursesSet: Set<String>
    @ObservationIgnored let defaults: UserDefaults = UserDefaults.standard
    var notificationSettings: CourseNotificationSettings = [] {
        didSet {
            if !notificationSettings.isEmpty {
                if let encoded = try? JSONEncoder().encode(notificationSettings) {
                    defaults.setValue(encoded, forKey: UserDefaults.DefaultKey.courseNotification.rawValue)
                    print("saved")
                }
            }
        }
    }
    var bannerMessage: ToastMessage = ToastMessage()
    init() {
        coursesSet = coursEventProvider.unqiueCourses
        updateAuthorization()
    }
    
    func updateAuthorization() {
        UNUserNotificationCenter.current().getNotificationSettings(){ (settings) in
            self.authorizationStatus = settings.authorizationStatus
            if self.authorizationStatus == .authorized || self.authorizationStatus == .provisional {
                if let defaultCourseNoti = self.defaults.data(forKey: UserDefaults.DefaultKey.courseNotification.rawValue) {
                    do {
                        let defaultSettings = try JSONDecoder().decode(CourseNotificationSettings.self, from: defaultCourseNoti)
                        let newSettings = self.getLastestNotificationSettings()
                        if defaultSettings != newSettings {
                            // had a new stuff in it. should make a alert here
                            print("detected new stuff, popup alert")
                            self.bannerMessage.showMessage(title: "⚠️Detected New Events⚠️", subtitle: "All notification settings have been reset as we have detected there are new courses or tutorials. You will need to re-enable settings by yourself!")
                            self.deregisterAllEvents(from: defaultSettings)
                            self.notificationSettings = newSettings
                        } else {
                            self.notificationSettings = defaultSettings
                        }
                        return
                    } catch {
                        self.notificationSettings = []
                        print("Unable to decode user default transcript, need to retrieve new data again")
                    }
                } else if !self.defaults.isKeyPresent(key: .courseNotification) {
                    // First time, initing the noti settings
                    let newSettings = self.getLastestNotificationSettings()
                    self.notificationSettings = newSettings
                }
            }
        }
    }
    
    func updateCourseNotiSetting(id: String, to newValue: Bool) {
        let currentNotificationCenter = UNUserNotificationCenter.current()
        if let courseNotiSetting = notificationSettings.first(where: {$0.id == id}) {
            if newValue {
                print("enabling noti for \(id)")
                let onlyFutureEvents = courseNotiSetting.allEvents.filter {
                    $0.eventStartDate > Date.now
                }
                let formatter = DateFormatter()
                formatter.timeStyle = .short
                print("enabling over \(onlyFutureEvents.count)")
                
                let calendar = Calendar.current
                let minusOneHour = DateComponents(hour: -1)
                
                for event in onlyFutureEvents {
                    let content = UNMutableNotificationContent()
                    let title = event.eventTitle.trimmingCharacters(in: .whitespacesAndNewlines)
                    let location = event.eventLocation.trimmingCharacters(in: .whitespacesAndNewlines)
                    content.title = "🏫 \(title)"
                    content.body = "\(formatter.string(from: event.eventStartDate)) - \(formatter.string(from: event.eventEndDate))\(location.isEmpty ? "" : " in \(location)")"
                    content.sound = UNNotificationSound.default
                    
                    let oneHourEarlier = Calendar.current.date(
                        byAdding: .hour,
                        value: -1,
                        to: event.eventStartDate)!
                    print(oneHourEarlier.description)
                    let timeInterval = oneHourEarlier.timeIntervalSince1970 - Date.now.timeIntervalSince1970
                    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
        
                    let request = UNNotificationRequest(identifier: event.eventID, content: content, trigger: trigger)
                    currentNotificationCenter.add(request) { result in
                        switch result {
                        case .none:
                            return
                        case .some(let error):
                            print("Error for \(id): \(error.localizedDescription)")
                            print("disabling.... as error occured")
                            let notiIdx = self.notificationSettings.firstIndex(of: courseNotiSetting)!
                            self.notificationSettings[notiIdx].notificationOn = false
                            let allEventIds = courseNotiSetting.allEvents.map {$0.eventID}
                            currentNotificationCenter.removePendingNotificationRequests(withIdentifiers: allEventIds)
                            print("removed all requests for this ")
                        }
                    }
                    print("added the request for \(id) on \(trigger.nextTriggerDate())")
                }
            } else {
                // remove noti
                print("removing noti for \(id)")
                let allEventIds = courseNotiSetting.allEvents.map {$0.eventID}
                currentNotificationCenter.removePendingNotificationRequests(withIdentifiers: allEventIds)
                currentNotificationCenter.removeDeliveredNotifications(withIdentifiers: allEventIds)
                print("submitted request for removal!")
            }
        }
    }
    
    private func getLastestNotificationSettings() -> CourseNotificationSettings {
        var eventsByCourseName = coursEventProvider.courseEventsByTitle
        let sortedCourseTitles = eventsByCourseName.keys.sorted()
        var notiSettings: CourseNotificationSettings = []
        for key in sortedCourseTitles {
            let event = eventsByCourseName[key]!
            notiSettings.append(CourseNotificationSetting(id: key, notificationOn: false, allEvents: event))
        }
        return notiSettings
    }
    
    private func deregisterAllEvents(from settings: CourseNotificationSettings) {
        print("removing all noti requests")
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}
