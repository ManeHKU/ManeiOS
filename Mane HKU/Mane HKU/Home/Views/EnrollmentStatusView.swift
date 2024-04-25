//
//  EnrollmentStatusView.swift
//  Mane HKU
//
//  Created by Yau Chin Pang on 28/2/2024.
//

import SwiftUI
import AlertToast

struct EnrollmentStatusView: View {
    @Bindable private var enrollmentVM: EnrollmentStatusViewModel = EnrollmentStatusViewModel()
    @Environment(AlertToastManager.self) private var alertToast: AlertToastManager
    let semesterOrder: [Semester] = {
        let monthDigit = Int(Date.now.formatted(Date.FormatStyle().month(.defaultDigits))) ?? -1
        //        return [.SEM1, .SEM2, .SUMMER]
        if monthDigit < 0 ||  8...12 ~= monthDigit  {
            return [.SEM1, .SEM2, .SUMMER]
        } else if 1...5 ~= monthDigit {
            return [.SEM2, .SUMMER]
        }
        return [.SUMMER]
    }()
    
    var body: some View {
        VStack {
            if let updatedTime = enrollmentVM.enrollmentStatus.lastUpdatedTime, let statusList = enrollmentVM.enrollmentStatus.enrollementStatusList {
                VStack {
                    HStack {
                        Text("Last Updated Time: \(updatedTime.formatted(date: .abbreviated, time: .shortened) )")
                            .padding(.bottom, 10)
                        Spacer()
                    }
                    ScrollView {
                        ForEach(semesterOrder) { currentSemester in
                            if let courses = statusList[currentSemester] {
                                VStack(alignment: .leading, spacing: 10) {
                                    Text(currentSemester.description)
                                        .font(.title3)
                                    ForEach(courses, id: \.code) { course in
                                        CourseEnrollmentStatusRow(courseEnrollmentStatus: course)
                                    }
                                }
                            }
                        }
                    }
                }
                Spacer()
            } else {
                Text("No enrollment status available")
            }
        }
        .padding(.all, 15)
        .padding(.bottom, 0)
        .navigationTitle("Enrollment Status")
        .navigationBarTitleDisplayMode(.large)
        .onChange(of: enrollmentVM.loading, initial: true) {
            alertToast.showLoading = enrollmentVM.loading
        }
        .onChange(of: enrollmentVM.normalMessage.show) {
            if enrollmentVM.normalMessage.show {
                alertToast.alertToast = AlertToast(displayMode: .hud, type: .regular, title: enrollmentVM.normalMessage.title, subTitle: enrollmentVM.normalMessage.subtitle)
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Refresh", systemImage: "arrow.clockwise") {
                    Task {
                        await enrollmentVM.retrieveNewEnrollmentStatus()
                    }
                }.disabled(enrollmentVM.loading || !PortalScraper.shared.isSignedIn)
                
            }
        }
    }
}

struct CourseEnrollmentStatusRow: View {
    let courseEnrollmentStatus: CourseInEnrollmentStatus
    @State var showFullSchedule = false
    
    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            ZStack {
                Group {
                    courseEnrollmentStatus.status.iconImage
                }
                .font(.title)
                Rectangle()
                    .fill(.gray)
                    .cornerRadius(10)
                    .opacity(0.4)
            }.frame(width: 60, height: 60, alignment: .center)
            VStack(alignment: .leading) {
                HStack {
                    Text("\(courseEnrollmentStatus.code) (\(courseEnrollmentStatus.subclass))")
                        .bold()
                        .font(.headline)
                    Button {
                        showFullSchedule = true
                    } label: {
                        Image(systemName: "calendar.circle.fill")
                            .font(.headline)
                    }
                    .popover(isPresented: $showFullSchedule, arrowEdge: .top) {
                        Text(courseEnrollmentStatus.schedule)
                            .presentationCompactAdaptation(.automatic)
                    }
                }
            }
            Spacer()
            Text(courseEnrollmentStatus.status == .unknown ? "Unknown" : courseEnrollmentStatus.status.rawValue)
        }
        .padding(.trailing, 10)
        .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/)
    }
}

#Preview {
    EnrollmentStatusView()
}
