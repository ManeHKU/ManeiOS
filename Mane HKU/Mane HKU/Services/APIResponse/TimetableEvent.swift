// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let eventListResponse = try? JSONDecoder().decode(EventListResponse.self, from: jsonData)

import Foundation

// MARK: - EventListResponse
struct EventListResponse: Codable {
    let eventList: TimetableEvents
    let error: Int
    let massage: String
    
    enum CodingKeys: String, CodingKey {
        case eventList = "event_list"
        case error, massage
    }
}
typealias TimetableEvents = [TimetableEvent]

// MARK: - EventList
struct TimetableEvent: Codable {
    let userID: UserID
    let eventID, eventTypeID, eventCategoryID, eventTitle: String
    let eventDetails: String?
    let eventFileID, eventLocation: String
    let eventStartDate, eventEndDate: Date
    let categoryDesc: CategoryDesc
    let typeDesc: TypeDesc
    let allDay, blacklist: Bool
    
    enum CodingKeys: String, CodingKey {
        case userID = "user_id"
        case eventID = "event_id"
        case eventTypeID = "event_type_id"
        case eventCategoryID = "event_category_id"
        case eventTitle = "event_title"
        case eventDetails = "event_details"
        case eventFileID = "event_file_id"
        case eventLocation = "event_location"
        case eventStartDate = "event_start_date"
        case eventEndDate = "event_end_date"
        case categoryDesc = "category_desc"
        case typeDesc = "type_desc"
        case allDay, blacklist
    }
}

enum CategoryDesc: String, Codable {
    case lectureTimetable = "Lecture Timetable"
    case registeredHKUEMSEvents = "Registered HKUEMS Events"
    case tutorialTimetable = "Tutorial Timetable"
    case universityHoliday = "University Holiday"
}

enum TypeDesc: String, Codable {
    case personalWorkEvents = "Personal/Work events"
    case universityWideEvents = "University-wide events"
}

enum UserID: String, Codable {
    case api = "API"
    case sysgen = "SYSGEN"
}

extension Formatter {
    static var eventDateISO8601DateFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFullDate, .withTime, .withFractionalSeconds, .withSpaceBetweenDateAndTime, .withDashSeparatorInDate, .withColonSeparatorInTime]
        formatter.timeZone = .init(identifier: "Asia/Hong_Kong")
        return formatter
    }()
}

extension JSONDecoder.DateDecodingStrategy {
    static var eventDate = custom { decoder in
        let dateStr = try decoder.singleValueContainer().decode(String.self)
        let customIsoFormatter = Formatter.eventDateISO8601DateFormatter
        if let date = customIsoFormatter.date(from: dateStr) {
            return date
        }
        throw DecodingError.dataCorrupted(
            DecodingError.Context(codingPath: decoder.codingPath,
                                  debugDescription: "Invalid date"))
    }
}

extension JSONDecoder {
    static var eventListDateJSONDecoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .eventDate
        return decoder
    }
}
