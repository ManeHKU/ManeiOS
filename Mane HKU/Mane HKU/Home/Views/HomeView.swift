//
//  HomeView.swift
//  Mane HKU
//
//  Created by Yau Chin Pang on 11/1/2024.
//

import SwiftUI
import AlertToast

struct HomeMenuItem: Identifiable {
    let id: HomeMenuType
    let title: String
    let subtitle: String?
}

enum HomeMenuType {
    case transcript
    case enrollmentStatus
    case calendar
    case courseReviews
    case campusEvent
}

struct HomeView: View {
    @State private var alertToastManager = AlertToastManager()
    @Bindable private var homeVM: HomeViewModel = HomeViewModel()
    @State private var showSettingSheet = false
    
    private var greetingMessage: String {
        let hour = Calendar.current.component(.hour, from: Date())
        if hour < 12 { return "Good morning" }
        if hour < 18 { return "Good afternoon" }
        return "Good evening"
    }
    
    private let homeMenuItems: [HomeMenuItem] = [
        HomeMenuItem(id: .transcript, title: "Transcript", subtitle: "See your academic records"),
        HomeMenuItem(id: .enrollmentStatus, title: "Enrollment Status", subtitle: "See your enrolled course status"),
        HomeMenuItem(id: .calendar, title: "Timetable", subtitle: "See your personal timetable"),
        HomeMenuItem(id: .courseReviews, title: "Course Reviews", subtitle: "See course reviews or add your own review"),
        HomeMenuItem(id: .campusEvent, title: "Campus Events", subtitle: "Check out the latest events happening in HKU!")
    ]
    
    var body: some View {
        NavigationStack{
            VStack(spacing: 10) {
                HStack {
                    Text("\(greetingMessage), \(homeVM.nickname)!")
                        .font(.title2)
                        .bold()
                    Spacer()
                    Button {
                        showSettingSheet.toggle()
                    } label: {
                        Image(systemName: "gear")
                    }
                }
                HStack {
                    Text("Have a great day")
                        .font(.title3)
                    Spacer()
                }
                
                Spacer()
                List {
                    ForEach(homeMenuItems) { item in
                        NavigationLink(value: item.id) {
                            ItemRow(title: item.title, subtitle: item.subtitle)
                        }
                        .listRowInsets(EdgeInsets())
                    }
                }
                .listStyle(.inset)
                .navigationDestination(for: HomeMenuType.self) { type in
                    switch type {
                    case .transcript:
                        TranscriptView()
                    case .enrollmentStatus:
                        EnrollmentStatusView()
                    case .calendar:
                        TimetableView()
                    case .courseReviews:
                        CourseReviewListsView()
                    case .campusEvent:
                        CampusEventListView()
                    }
                }
            }
            .padding(.all, 15)
            .navigationTitle("Home")
            .navigationBarTitleDisplayMode(.large)
        }
        .sheet(isPresented: $showSettingSheet) {
            SettingsView()
                .presentationDetents([.medium, .large])
        }
        .environment(alertToastManager)
        .toast(isPresenting: $alertToastManager.show){
            alertToastManager.alertToast
        }
        .toast(isPresenting: $alertToastManager.showLoading){
            alertToastManager.loadingToast
        }
        .onChange(of: homeVM.loading, initial: true) {
            alertToastManager.showLoading = homeVM.loading
        }
        .onChange(of: homeVM.successMessage.show) {
            if homeVM.successMessage.show {
                alertToastManager.alertToast = AlertToast(displayMode: .alert, type: .complete(.green), title: homeVM.successMessage.title, subTitle: homeVM.successMessage.subtitle)
            }
        }
        .onChange(of: homeVM.errorMessage.show) {
            if homeVM.errorMessage.show {
                alertToastManager.alertToast = AlertToast.createErrorToast(title: homeVM.errorMessage.title, subtitle: homeVM.errorMessage.subtitle)
            }
        }
    }
}

struct ItemRow: View {
    let title: String
    let subtitle: String?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .fontWeight(.medium)
            if let unwrappedSubtitle = subtitle {
                Text(unwrappedSubtitle)
                    .foregroundStyle(.gray)
            }
        }
        .padding(.vertical, 10)
    }
}

#Preview {
    HomeView()
}
