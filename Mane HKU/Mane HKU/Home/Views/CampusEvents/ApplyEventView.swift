//
//  ApplyEventView.swift
//  Mane HKU
//
//  Created by Yau Chin Pang on 11/4/2024.
//

import SwiftUI
import AlertToast

struct ApplyEventView: View {
    @Environment(AlertToastManager.self) private var alertToast: AlertToastManager
    @Environment(\.dismiss) private var dismiss
    @Bindable private var applyVM: ApplyEventViewModel
    let eventID: String
    let applyInfo: Events_ApplyInfo
    
    init(eventID: String, applyInfo: Events_ApplyInfo) {
        self.eventID = eventID
        self.applyInfo = applyInfo
        self.applyVM = ApplyEventViewModel(applyInfo: applyInfo, eventID: eventID)
    }
    
    var body: some View {
        Form {
            if applyInfo.hasInfo {
                Section("Read before you proceed") {
                    Text(applyInfo.info)
                    Toggle("I understand", isOn: $applyVM.hasReadInfo)
                }
            }
            
            if !applyInfo.questions.isEmpty {
                ForEach(applyInfo.questions.indices, id: \.self) { i in
                    Section(applyInfo.questions[i]) {
                        TextField("Type your response here", text: $applyVM.answers[i])
                    }
                }
            }
            
            Section {
                Button("Apply") {
                    Task {
                        await applyVM.applyEvent()
                    }
                }
                .disabled(!applyVM.validForm || applyVM.loading)
            } footer: {
                if !applyInfo.questions.isEmpty {
                    Text("Make sure to confirm all the details are correct")
                }
            }
        }
        .navigationTitle("Apply Event")
        .onChange(of: applyVM.errorMessage.show) {
            if applyVM.errorMessage.show {
                alertToast.bannerToast = AlertToast(displayMode: .banner(.slide), type: .error(.red), title: applyVM.errorMessage.title, subTitle: applyVM.errorMessage.subtitle)
            }
        }
        .onChange(of: applyVM.appliedEvent) {
            if applyVM.appliedEvent {
                alertToast.alertToast = AlertToast(displayMode: .alert, type: .complete(.green), title: "Applied Event!🎉")
                dismiss()
            }
        }
    }
}

//#Preview {
//    ApplyEventView()
//}
