//
//  AddCourseReviewSheetView.swift
//  Mane HKU
//
//  Created by Yau Chin Pang on 4/4/2024.
//

import SwiftUI
import AlertToast

struct AddCourseReviewSheetView: View {
    let courseCode: String
    let successFunction:  () -> Void
    @Bindable private var addReviewVM: AddCourseReviewViewModel
    @Environment(\.dismiss) private var dismiss
    
    init(courseCode: String, successFunction: @escaping () -> Void) {
        self.courseCode = courseCode
        self.addReviewVM = AddCourseReviewViewModel(courseCode: courseCode)
        self.successFunction = successFunction
    }
    
    var body: some View {
        Form {
            Section {
                Picker("Academic Year", selection: $addReviewVM.selectedYear) {
                    ForEach(Reviews_AcademicYear.allCases.filter {$0.getString() != "UNSUPPORTED"}, id: \.self) { year in
                        Text(year.getString()).tag(year.rawValue)
                    }
                }
                Picker("Semester", selection: $addReviewVM.selectedSemester) {
                    ForEach(Reviews_Semester.allCases, id: \.self) { semester in
                        Text(semester.getString()).tag(semester.rawValue)
                    }
                }
            } header: {
                Text("When did you take the course?")
            } footer: {
                if !addReviewVM.timeError.isEmpty {
                    Text(addReviewVM.timeError)
                        .font(.caption)
                        .foregroundStyle(.pink)
                }
            }
            
            Section{
                //                Stepper("Rating: \(addReviewVM.rating)/5", value: $addReviewVM.rating, in: 1...5)
                Picker("Rate course: ", selection: $addReviewVM.rating) {
                    ForEach(1...5, id: \.self) {
                        Text("\($0)")
                            .tag($0)
                    }
                }
                .pickerStyle(.segmented)
                TextEditor(text: $addReviewVM.content)
            } header: {
                Text("Review")
            } footer: {
                if !addReviewVM.reviewError.isEmpty {
                    Text(addReviewVM.lecturerError)
                        .font(.caption)
                        .foregroundStyle(.pink)
                }
            }
            
            Section {
                Stepper("Number of lecturers: \(addReviewVM.numOfLecturers + 1)", value: $addReviewVM.numOfLecturers, in: 0...4)
                ForEach(0...addReviewVM.numOfLecturers, id: \.self) {
                    TextField("Lecturer \($0 + 1)", text: $addReviewVM.lecturers[$0])
                }
            } header: {
                Text("Lecturers")
            } footer: {
                if !addReviewVM.lecturerError.isEmpty {
                    Text(addReviewVM.lecturerError)
                        .font(.caption)
                        .foregroundStyle(.pink)
                }
            }
            
            Section {
                Button("Submit") {
                    addReviewVM.resetAllError()
                    guard addReviewVM.validForm else {
                        addReviewVM.errorForm = "Please recheck the details you have inputted. Invalid field(s) have been found!"
                        return
                    }
                    Task {
                        await addReviewVM.submitAddReview()
                    }
                }
                .disabled(!addReviewVM.validForm || addReviewVM.loading)
                Button("Cancel") {
                    dismiss()
                    addReviewVM.resetToDefault()
                }
                .disabled(addReviewVM.loading)
            } footer: {
                if !addReviewVM.errorForm.isEmpty {
                    Text(addReviewVM.errorForm)
                        .font(.caption)
                        .foregroundStyle(.pink)
                }
            }
        }.onChange(of: addReviewVM.reviewAdded) {
            if addReviewVM.reviewAdded {
                self.successFunction()
                dismiss()
            }
        }
    }
}

//#Preview {
//    func addedReviewSuccessfully() {
//        print("lmaooo")
//    }
//    AddCourseReviewSheetView(courseCode: "COMP3323", successFunction: addedReviewSuccessfully)
//}
