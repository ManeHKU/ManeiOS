//
//  DayView.swift
//  Mane HKU
//
//  Created by Yau Chin Pang on 20/3/2024.
//

import MijickCalendarView
import Foundation
import SwiftUI


//
//  DayView.ColoredCircle.swift of CalendarView Demo
//
//  Created by Alina Petrovska on 02.12.2023.
//    - Mail: alina.petrovskaya@mijick.com
//    - GitHub: https://github.com/Mijick
//
//  Copyright ©2023 Mijick. Licensed under MIT License.

struct ColoredCircle: DayView {
    var date: Date
    var color: Color?
    var isCurrentMonth: Bool
    var selectedDate: Binding<Date?>?
    var selectedRange: Binding<MDateRange?>?
    
    func createDayLabel() -> AnyView {
        ZStack {
            createDayLabelBackground()
            createDayLabelText()
        }
        .erased()
    }
    
    func createDayLabelBackground() -> some View {
        Circle()
            .fill(isSelected() ? .onBackgroundPrimary : color ?? .clear)
            .padding(4)
    }
    func createDayLabelText() -> some View  {
        Text(getStringFromDay(format: "d"))
            .font(.system(size: 17))
            .foregroundColor(getTextColor())
            .strikethrough(isPast())
    }
    func getTextColor() -> Color {
            guard !isPast() else { return .onBackgroundSecondary }
            
            switch isSelected() {
                case true: return .accent
                case false: return color == nil ? .onBackgroundPrimary : .white
            }
        }
    
    func getBackgroundColor() -> Color {
        guard !isPast() else { return .clear }

        switch isSelected() {
            case true: return .onBackgroundPrimary
            case false: return color ?? .clear
        }
    }
}


// MARK: - On Selection Logic
extension ColoredCircle {
    func onSelection() {
        if !isPast() { selectedDate?.wrappedValue = date }
    }
}
