//
//  TimetableView.swift
//  Mane HKU
//
//  Created by Yau Chin Pang on 7/3/2024.
//

import SwiftUI
import MijickCalendarView

struct TimetableView: View {
    @Bindable internal var timetableVM: TimetableViewModel = TimetableViewModel()
    @State private var selectedDate: Date? = Date.now
    @State private var selectedRange: MDateRange? = .init(startDate: Date.now, endDate: Calendar.current.date(byAdding: .year, value: 1, to: Date.init())!)
    @State private var openNotificationSheet = false
    let endMonth: Date = Calendar.current.date(byAdding: .year, value: 1, to: Date.init())!
    
    var body: some View {
        VStack {
            if timetableVM.loading {
                Text("Loading...")
            } else {
                if let events = timetableVM.events, !events.isEmpty {
                    MCalendarView(selectedDate: $selectedDate, selectedRange: $selectedRange, configBuilder: configureCalendar)
                    Spacer(minLength: 20)
                    VStack {
                        EventsDayView(selectedDate: $selectedDate, events: events)
                        Spacer()
                    }.frame(maxHeight: UIScreen.main.bounds.height * 0.3)
                } else {
                    Text("No timetable available. Try refreshing?")
                        .font(.largeTitle)
                }
                
            }
        }
        .padding(.horizontal, 15)
        .sheet(isPresented: $openNotificationSheet) {
            CourseNotificationsView()
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
                .presentationBackground(Material.thinMaterial)
        }
        .navigationTitle("Timetable")
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                Button("Refresh", systemImage: "arrow.clockwise") {
                    Task {
                        await timetableVM.updateEvents()
                    }
                }.disabled(timetableVM.loading || !PortalScraper.shared.isSignedIn)
                Button("Notifications", systemImage: "bell.badge.fill") {
                    openNotificationSheet.toggle()
                }.disabled(timetableVM.loading || !PortalScraper.shared.isSignedIn)
                Button("Export", systemImage: "square.and.arrow.up.fill") {
                    Task {
                        //                            await enrollmentVM.retrieveNewEnrollmentStatus()
                    }
                }.disabled(timetableVM.loading || !PortalScraper.shared.isSignedIn)
            }
        }
    }
}

extension TimetableView {
    func configureCalendar(_ config: CalendarConfig) -> CalendarConfig {
        config
            .startMonth(Date.now)
            .endMonth(endMonth)
            .monthsTopPadding(36)
            .monthsBottomPadding(8)
            .daysHorizontalSpacing(1)
            .daysVerticalSpacing(3)
            .dayView(buildDayView)
    }
}

private extension TimetableView {
    func buildDayView(_ date: Date, _ isCurrentMonth: Bool, selectedDate: Binding<Date?>?, range: Binding<MDateRange?>?) -> ColoredCircle {
        return .init(date: date, color: getDateColor(date), isCurrentMonth: isCurrentMonth, selectedDate: selectedDate, selectedRange: nil)
    }
    func getDateColor(_ date: Date) -> Color? {
        guard let eventsOnDate = timetableVM.events?[date.getYMDComponents()] else {
            return nil
        }
        let isHKUHoliday = eventsOnDate.contains(where: { $0.categoryDesc == .universityHoliday })
        return isHKUHoliday ? .pink : .accentColor
    }
}


#Preview {
    TimetableView()
}
