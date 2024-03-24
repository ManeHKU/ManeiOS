//
//  CourseTimetableProvider.swift
//  Mane HKU
//
//  Created by Yau Chin Pang on 23/3/2024.
//

import Foundation

enum CourseTimetableError: Error {
    case PortalNotSignedIn, FailToRetrieve
}

@Observable final class CourseEventProvider {
    static let shared = CourseEventProvider()
    @ObservationIgnored let defaults = UserDefaults.standard
    var eventsByDateComponents: [DateComponents: TimetableEvents]? {
        get {
            if _timetableEvents.isEmpty {
                return nil
            }
            return Dictionary(grouping: sortedEvents) { (event) -> DateComponents in
                event.eventStartDate.getYMDComponents()
            }
        }
    }
    var courseEventsByTitle: [String: TimetableEvents] {
        get {
            let filtered = sortedEvents.filter {
                $0.categoryDesc.isCourseEvent(withExams: true)
            }
            return Dictionary(grouping: filtered) {$0.eventTitle}
        }
    }
    var sortedEvents: TimetableEvents {
        get {
            _timetableEvents.sorted { a, b in
                a.eventStartDate < b.eventStartDate
            }
        }
    }
    var unqiueCourses: Set<String> {
        get {
            let coursesOnly = _timetableEvents.filter {
                $0.categoryDesc == .lectureTimetable || $0.categoryDesc == .tutorialTimetable
            }
            var output = Set<String>()
            for course in coursesOnly {
                output.insert(course.eventTitle)
            }
            return output
        }
    }
    private var _timetableEvents: TimetableEvents = [] {
        didSet {
            if !_timetableEvents.isEmpty {
                if let encoded = try? JSONEncoder().encode(_timetableEvents) {
                    defaults.setValue(encoded, forKey: UserDefaults.DefaultKey.timetable.rawValue)
                    print("updated user defaults")
                }
            }
        }
    }
    
    func getEvents() async throws -> [DateComponents: TimetableEvents]?{
        if _timetableEvents.isEmpty {
            if let localEvents = retrieveLocalEvents() {
                return localEvents
            }
            let newEvents = try await retrieveNewEvents()
            return newEvents
        }
        return eventsByDateComponents
    }
    
    @discardableResult
    func retrieveLocalEvents() -> [DateComponents: TimetableEvents]? {
        if let defaultTimetable = defaults.data(forKey: UserDefaults.DefaultKey.timetable.rawValue) {
            do {
                self._timetableEvents = try JSONDecoder().decode(TimetableEvents.self, from: defaultTimetable)
                return eventsByDateComponents
            } catch {
                print("Unable to decode user default timetable, need to retrieve new data again")
            }
        }
        return nil
    }
    
    @discardableResult
    func retrieveNewEvents() async throws -> [DateComponents: TimetableEvents]? {
        if !PortalScraper.shared.isSignedIn {
            throw CourseTimetableError.PortalNotSignedIn
        }
        _timetableEvents = await PortalScraper.shared.getEventList()
        print("received event list with len: \(_timetableEvents.count)")
        if _timetableEvents.isEmpty {
            throw CourseTimetableError.FailToRetrieve
        }
        return eventsByDateComponents
    }
}

extension Date {
    func getYMDComponents() -> DateComponents {
        Calendar.current.dateComponents([.year, .month, .day], from: (self))
    }
}
