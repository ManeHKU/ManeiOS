//
//  AddEventView.swift
//  Mane HKU
//
//  Created by Yau Chin Pang on 11/4/2024.
//

import SwiftUI
import PhotosUI
import AlertToast

struct AddEventView: View {
    @Environment(AlertToastManager.self) private var alertToast: AlertToastManager
    @Environment(\.dismiss) private var dismiss
    @Bindable private var addVM: AddEventViewModel
    @FocusState private var isEditorFocused: Bool
    let userAdminOf: [Events_OrganizerInfo]
    
    init(orgs: [Events_OrganizerInfo]) {
        self.userAdminOf = orgs
        self.addVM = AddEventViewModel(firstOrganizationId: userAdminOf.first!.id)
    }
    
    var body: some View {
        if userAdminOf.isEmpty {
            Text("User is not an admin of any organization.")
        } else {
            Form {
                Picker("Organization", selection: $addVM.pickedOrganization) {
                    ForEach(userAdminOf, id: \.id) {
                        Text($0.name).tag($0.id)
                    }
                }.pickerStyle(.inline)
                
                Section("Event info") {
                    TextField("Title", text: $addVM.title)
                    TextField("Location", text: $addVM.location)
                    DatePicker("Start Time", selection: $addVM.startDate)
                    DatePicker("End Time", selection: $addVM.endDate)
                    Picker("Max Participants", selection: $addVM.participationLimt) {
                        ForEach(2..<100) {
                            Text("\($0) people").tag($0)
                        }
                    }
                }
                
                Section {
                    if addVM.photoItem == nil {
                        PhotosPicker(selection: $addVM.photoItem,
                                     matching: .all(of: [.images, .not(.livePhotos)])) {
                            Text("Add Image")
                        }
                    } else {
                        switch addVM.imageState {
                        case .retrieving(_):
                            ProgressView()
                                .frame(maxWidth: .infinity, alignment: .center)
                        case .success(_):
                            if let displayImage = addVM.displayImage {
                                displayImage
                                    .resizable()
                                    .scaledToFit()
                                    .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, maxHeight: 400, alignment: .center)
                                PhotosPicker(selection: $addVM.photoItem,
                                             matching: .all(of: [.images, .not(.livePhotos)])) {
                                    Text("Upload New Image")
                                }
                            }
                        case nil, .failure(_):
                            EmptyView()
                        }
                    }
                } header: {
                    Text("IMAGE (Optional)")
                } footer: {
                    Text("Try to upload a landscape image. It'll look much better!")
                }
                
                Section("Event description") {
                    ZStack(alignment: .topLeading) {
                        if addVM.description.isEmpty && !isEditorFocused{
                            Text("Type your description here")
                                .foregroundStyle(.secondary)
                                .font(.footnote)
                        }
                        
                        TextEditor(text: $addVM.description)
                            .focused($isEditorFocused)
                            .frame(minHeight: 100)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                
                Section {
                    TextEditor(text: $addVM.applyInfo)
                        .frame(height: 100)
                } header: {
                    Text("Apply Info (Optional)")
                } footer: {
                    Text("This section would be shown to the user when they are trying to apply to your event. You can put any kind of safety notes or reminder. They would need to explicitly state they understand the notes in order to continue.")
                }
                
                Section {
                    Stepper("Number of questions: \(addVM.numOfQuestions)", value: $addVM.numOfQuestions, in: 0...5)
                    if addVM.numOfQuestions > 0 {
                        ForEach(1...addVM.numOfQuestions, id: \.self) {
                            TextField("Question \($0)", text: $addVM.questions[$0 - 1])
                        }
                    }
                } header: {
                    Text("Questions (Optional)")
                } footer: {
                    Text("These question(s) are shown to the user when they are trying to apply to your event. Each student is required to answer the questions to proceed.")
                }
                
                Button("Add Event") {
                    Task {
                        await addVM.addEvent()
                    }
                }.disabled(!addVM.validForm || addVM.loading)
            }
            .onChange(of: addVM.loading) {
                alertToast.showLoading = addVM.loading
            }
            .onChange(of: addVM.errorAlert.show) {
                alertToast.alertToast = AlertToast(displayMode: .alert, type: .error(.red), title: addVM.errorAlert.title)
            }
            .onChange(of: addVM.errorMessage.show) {
                alertToast.alertToast = AlertToast(displayMode: .banner(.slide), type: .error(.red), title: addVM.errorAlert.title, subTitle: addVM.errorMessage.subtitle)
            }
            .onChange(of: addVM.addEventResult) {
                if let result = addVM.addEventResult {
                    if result {
                        alertToast.alertToast = AlertToast(displayMode: .alert, type: .complete(.green), title: "Added Event!🎉")
                        dismiss()
                    } else {
                        addVM.addEventResult = nil
                        addVM.errorAlert.showMessage(title: "Unknown error!", subtitle: nil)
                    }
                }
            }
            .navigationTitle("Add Event")
        }
    }
}

#Preview {
    var org = Events_OrganizerInfo()
    org.id = "test1234"
    org.name = "Coffee club"
    org.description_p = "sdasdasdasd"
    var org2 = Events_OrganizerInfo()
    org2.id = "ye923920321"
    org2.name = "Chicken Club"
    org2.description_p = "dsajd dijvjd visadas"
    let orgs: [Events_OrganizerInfo] = [org, org2]
    return AddEventView(orgs: orgs)
}
