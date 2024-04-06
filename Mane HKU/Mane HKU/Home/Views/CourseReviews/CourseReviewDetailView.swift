//
//  CourseReviewDetailView.swift
//  Mane HKU
//
//  Created by Yau Chin Pang on 1/4/2024.
//

import SwiftUI
import ExpandableText
import AlertToast

struct CourseReviewDetailView: View {
    let courseCode: String
    @Environment(AlertToastManager.self) private var alertToast: AlertToastManager
    @Bindable private var detailVM: CourseReviewDetailViewModel
    @State private var addReviewSheet = false
    @State private var loading = true
    @State private var addReviewResult: AddReviewResult = .nothing {
        didSet {
            if addReviewResult == .success {
                successAddReviewAlert = true
            }
        }
    }
    @State private var successAddReviewAlert = false
    init(courseCode: String) {
        self.courseCode = courseCode
        self.detailVM = CourseReviewDetailViewModel(courseCode: courseCode)
    }
    
    var body: some View {
        VStack(alignment: .leading){
            if let courseDetail = detailVM.courseDetail{
                VStack(alignment: .leading, spacing: 5) {
                    CourseDetailComponent(courseDetail: courseDetail)
                    Spacer()
                    if detailVM.reviews.isEmpty {
                        VStack(alignment: .center) {
                            Spacer()
                            HStack {
                                Spacer()
                                Text("No reviews for this course yet... 😢")
                                    .font(.callout)
                                Spacer()
                            }
                            Spacer()
                        }
                    } else {
                        List {
                            Section(header: Text("Reviews")) {
                                ForEach(detailVM.reviews, id: \.self) { item in
                                    ReviewItemView(review: item)
                                }
                            }
                            .headerProminence(.increased)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .topLeading)
            } else if !detailVM.loading {
                Text("Unable to find course \(courseCode)")
                    .font(.callout)
            }
        }
        .onChange(of: detailVM.loading, initial: true) {
            alertToast.showLoading = detailVM.loading
        }
        .onChange(of: detailVM.errorMessage.show) {
            if detailVM.errorMessage.show {
                alertToast.alertToast = AlertToast(displayMode: .banner(.slide), type: .error(.pink), title: detailVM.errorMessage.title, subTitle: detailVM.errorMessage.subtitle)
            }
        }
        .onChange(of: detailVM.normalMessage.show) {
            if detailVM.normalMessage.show {
                alertToast.alertToast = AlertToast(displayMode: .banner(.slide), type: .regular, title: detailVM.normalMessage.title, subTitle: detailVM.normalMessage.subtitle)
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Add Review", systemImage: "square.and.pencil") {
                    guard let meta = detailVM.addCourseMeta else {
                        detailVM.errorMessage.showMessage(title: "Error", subtitle: "Try again later")
                        return
                    }
                    if meta.userHasReviewed {
                        alertToast.alertToast = AlertToast(displayMode: .banner(.slide), type: .error(.pink), title: "Whoops!😢", subTitle:  "You have reviewed the course already!")
                        return
                    } else if !meta.userHasTakenCourse{
                        alertToast.alertToast = AlertToast(displayMode: .banner(.slide), type: .error(.pink), title: "Whoops!😢", subTitle:   "You cannot review course you haven't taken!")
                        return
                    }
                    addReviewSheet.toggle()
                }.disabled(detailVM.loading)
            }
        }
        .frame(maxWidth: .infinity)
        .navigationTitle(courseCode)
        .navigationBarTitleDisplayMode(.large)
        .sheet(isPresented: $addReviewSheet) {
            NavigationStack {
                AddCourseReviewSheetView(courseCode: courseCode, successFunction: addedReviewSuccessfully)
                    .presentationDragIndicator(.visible)
                    .presentationBackground(Material.thinMaterial)
                    .navigationTitle("Add review for \(courseCode)")
                    .navigationBarTitleDisplayMode(.inline)
            }
        }
        .padding(.horizontal, 15)
        .toast(isPresenting: $successAddReviewAlert) {
            AlertToast(displayMode: .alert, type: .complete(.green), title: "Review added!")
        }
        .onChange(of: addReviewResult) {
            if addReviewResult == .success {
                Task {
                    await detailVM.fetchCourseDetail()
                }
            }
        }
    }
    
    func addedReviewSuccessfully() {
        self.addReviewResult = .success
    }
    
    struct CourseDetailComponent: View {
        let courseDetail: Courses_Course
        var body: some View {
            VStack(alignment: .leading, spacing: 5) {
                Text(courseDetail.title)
                    .bold()
                    .font(.title)
                Group {
                    if courseDetail.rating == 0 {
                        Text("No reviews yet")
                            .foregroundStyle(.pink)
                    } else {
                        HStack {
                            Image(systemName: "star.fill")
                            Text("\(courseDetail.rating, specifier: "%.2f")/5")
                        }
                        .foregroundStyle(.accent)
                    }
                }
                .font(.headline)
                if courseDetail.offered {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                        Text("Offered in the current academic year")
                    }.foregroundStyle(.accent)
                } else {
                    HStack {
                        Image(systemName: "xmark.circle.fill")
                        Text("Not offered in the current academic year")
                    }.foregroundStyle(.pink)
                }
                Text("Offered by \(courseDetail.department)")
                    .font(.headline)
                if courseDetail.description_p.isEmpty {
                    Text("No description")
                } else {
                    ExpandableText(courseDetail.description_p)
                        .moreButtonText("read more")
                        .enableCollapse(true)
                }
            }
        }
    }
    
    struct ReviewItemView: View {
        let review: Reviews_Review
        var body: some View {
            VStack(alignment: .leading, spacing: 5) {
                HStack {
                    Text("\(review.yearTaken.getString()) \(review.semesterTaken.getString())")
                    Spacer()
                    HStack {
                        Image(systemName: "star.fill")
                        Text("\(review.rating)/5")
                    }
                    .foregroundStyle(review.rating > 2 ? .accent : .pink)
                }
                .font(.headline)
                Text(review.lecturers.count > 1 ?
                     "Lecturers: \(review.lecturers.joined(separator: ", "))":
                        "Lecturer: \(review.lecturers.joined(separator: ", "))"
                )
                .font(.subheadline)
                Text(review.content)
                Text("Written on \(review.createdAt.date, format: .dateTime.day().month().year())")
                    .foregroundStyle(.secondary)
                    .font(.footnote)
            }
        }
    }
}

extension Reviews_AcademicYear {
    func getString() -> String{
        switch self {
        case .ay20182019:
            "2018-2019"
        case .ay20192020:
            "2019-2020"
        case .ay20202021:
            "2020-2021"
        case .ay20212022:
            "2021-2022"
        case .ay20222023:
            "2022-2023"
        case .ay20232024:
            "2023-2024"
        default:
            "UNSUPPORTED"
        }
    }
}

extension Reviews_Semester {
    func getString() -> String {
        switch self {
        case .sem1:
            "Semester 1"
        case .sem2:
            "Semester 2"
        case .summer:
            "Summer Sem"
        case .UNRECOGNIZED(_):
            "Unknown Semester"
        }
    }
}

enum AddReviewResult {
    case success, nothing
}

#Preview {
    CourseReviewDetailView(courseCode: "COMP3330")
}
