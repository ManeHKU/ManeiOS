//
//  CourseNotificationsView.swift
//  Mane HKU
//
//  Created by Yau Chin Pang on 21/3/2024.
//

import SwiftUI
import UserNotifications
import AlertToast

struct CourseNotificationsView: View {
    private let notificationManager = CourseNotificationManager()
    @State var askedForAuth = false
    var body: some View {
        VStack {
            Group {
                if let status = notificationManager.authorizationStatus {
                    switch status {
                    case .notDetermined:
                        Text("Click allow to allow notifcations to show up")
                            .font(.callout)
                            .task(delayGoToSettings)
                    case .denied:
                        Text("⚠️ Please go to iPhone settings to enable notifcation for Mane to proceed")
                            .font(.callout)
                            .task(delayGoToSettings)
                    case .authorized, .provisional:
                        NotificationCenterView()
                    case .ephemeral:
                        Text("impossible")
                    }
                }
                else {
                    Text("Unknown Error. Try again")
                }
            }
        }.onAppear {
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
                notificationManager.updateAuthorization()
                askedForAuth = true
                if success {
                    print("All set!")
                } else if let error {
                    print(error.localizedDescription)
                }
            }
        }
        .onAppear(perform: updateAuthorization)
        .onReceive(
            NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)
          ) { _ in
              updateAuthorization()
          }
    }
    
    private func delayGoToSettings() async {
        try? await Task.sleep(nanoseconds: 3_000_000_000)
        if let appSettings = await URL(string: UIApplication.openSettingsURLString), await UIApplication.shared.canOpenURL(appSettings) {
            DispatchQueue.main.async {
                UIApplication.shared.open(appSettings)
            }
        }
    }
    
    private func updateAuthorization() {
        if askedForAuth {
            notificationManager.updateAuthorization()
        }
    }
}

struct NotificationCenterView: View {
    @Bindable private var courseNotiManager = CourseNotificationManager()
    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            Text("Course Notification Settings")
                .font(.headline)
                .padding(.top, 10)
            Spacer()
            if courseNotiManager.notificationSettings.isEmpty {
                Text("Unknown error. Settings are not available yet!")
                    .font(.callout)
                Spacer()
            } else {
                Form {
                    Section(header: Text("Notifications Setting")) {
                        ForEach($courseNotiManager.notificationSettings, id: \.id) { $course in
                            Toggle(course.id, isOn: $course.notificationOn)
                                .onChange(of: course.notificationOn) { _, newValue in
                                    courseNotiManager.updateCourseNotiSetting(id: course.id, to: newValue)
                                }
                        }
                    }
                }
                .scrollContentBackground(.hidden)
            }
        }
        .padding(.all, 15)
        .toast(isPresenting: $courseNotiManager.bannerMessage.show) {
            AlertToast(displayMode: .banner(.slide), type: .regular, title: courseNotiManager.bannerMessage.title, subTitle: courseNotiManager.bannerMessage.subtitle)
        }
    }
}

