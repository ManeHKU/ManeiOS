//
//  EventsDayView.swift
//  Mane HKU
//
//  Created by Yau Chin Pang on 20/3/2024.
//

import SwiftUI

extension TimetableView {
    struct EventsDayView: View {
        @Binding var selectedDate: Date?
        let events: [DateComponents: TimetableEvents]
        let timeFormatter = {
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            return formatter
        }()
        var day: String {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "EEEE, d MMMM"
            return dateFormatter.string(from: selectedDate ?? Date())
        }
        var title: String {
            guard let selectedDate else { return "" }
            if Calendar.current.isDateInToday(selectedDate) { return "TODAY" }
            else { return day.uppercased() }
        }
        
        var body: some View {
            VStack(spacing: 25) {
                createTitle()
                createContent()
            }
        }
        
        func createTitle() -> some View {
            Text(title)
                .font(.system(size: 20))
                .bold()
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        
        @ViewBuilder func createContent() -> some View {
            if selectedDate == nil {
                Text("Select a date")
            }
            switch events[selectedDate!.getYMDComponents()] {
            case .some(let events): createEventsList(events)
            case .none: Text("Wohoo no classes for you!")
            }
        }
        
        func createEventsList(_ events: TimetableEvents) -> some View {
            VStack(spacing: 16) {
                ForEach(events, id: \.eventID, content: createElement)
            }
        }
        func createElement(_ event: TimetableEvent) -> some View {
            HStack(spacing: 10) {
//                createColoredIndicator(event)
                
                VStack(spacing: 4) {
                    createEventTitle(event)
                    createEventSubtitle(event)
                }
                VStack(spacing: 4) {
                    createTimeRange(event)
                }.frame(alignment: .trailing)
            }
        }
    }
}

private extension TimetableView.EventsDayView {
//    func createColoredIndicator(_ event: TimetableEvent) -> some View  {
//        RoundedRectangle(cornerRadius: 3)
//            .fill(event.color)
//            .frame(width: 6, height: 20)
//    }
    func createEventTitle(_ event: TimetableEvent) -> some View {
        Text(event.eventTitle)
            .font(.system(size: 14))
            .fontWeight(.semibold)
            .foregroundStyle(event.allDay ? .accent : .onBackgroundPrimary)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
    func createEventSubtitle(_ event: TimetableEvent) -> some View {
        Text(event.eventLocation)
            .font(.system(size: 14))
            .foregroundStyle(.onBackgroundSecondary)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
    func createTimeRange(_ event: TimetableEvent) -> some View {
        Group {
            if event.categoryDesc == .universityHoliday {
                Text("Holiday!!")
                    .foregroundStyle(.red)
                Text("Wohoooo!!")
                    .foregroundStyle(.red)
            } else {
                Text(timeFormatter.string(from: event.eventStartDate))
                    .foregroundStyle(.onBackgroundPrimary)
                Text(timeFormatter.string(from: event.eventEndDate))
                    .foregroundStyle(.onBackgroundPrimary)
            }
        }
        .font(.system(size: 14))
    }
}
