//
//  CourseNotificationSettings.swift
//  Mane HKU
//
//  Created by Yau Chin Pang on 24/3/2024.
//

import Foundation

struct CourseNotificationSetting: Codable, Equatable {
    static func == (lhs: CourseNotificationSetting, rhs: CourseNotificationSetting) -> Bool {
        lhs.id == rhs.id && lhs.allEvents == rhs.allEvents
    }
    
    let id: String
    var notificationOn = false
    var allEvents: TimetableEvents
    var noMoreFutureEvents = false
}

typealias CourseNotificationSettings = [CourseNotificationSetting]
