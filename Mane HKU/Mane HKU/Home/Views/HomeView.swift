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
}

struct HomeView: View {
    @Bindable private var homeVM: HomeViewModel = HomeViewModel()
    
    private var greetingMessage: String {
        let hour = Calendar.current.component(.hour, from: Date())
        if hour < 12 { return "Good morning" }
        if hour < 18 { return "Good afternoon" }
        return "Good evening"
    }
    
    private let homeMenuItems: [HomeMenuItem] = [
        HomeMenuItem(id: .transcript, title: "Transcript", subtitle: "See your academic records"),
        HomeMenuItem(id: .enrollmentStatus, title: "Enrollment Status", subtitle: "See your enrolled course status")
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
                        Text("On9")
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
                    }
                }
            }
            .padding(.all, 15)
            .navigationTitle("Home")
            .navigationBarTitleDisplayMode(.large)
        }
        .toast(isPresenting: $homeVM.loading) {
            AlertToast(displayMode: .alert, type: .loading)
        }
        .toast(isPresenting: $homeVM.successMessage.show) {
            AlertToast(displayMode: .alert, type: .complete(.green), title: homeVM.successMessage.title, subTitle: homeVM.successMessage.subtitle)
        }
        .toast(isPresenting: $homeVM.errorMessage.show) {
            AlertToast.createErrorToast(title: homeVM.errorMessage.title, subtitle: homeVM.errorMessage.subtitle)
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
