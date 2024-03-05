//
//  TranscriptView.swift
//  Mane HKU
//
//  Created by Yau Chin Pang on 14/2/2024.
//

import SwiftUI
import AlertToast

struct TranscriptView: View {
    @Bindable private var transcriptVM: TranscriptViewModel = TranscriptViewModel()
    
    var titleSection: some View {
        VStack {
            HStack{
                Text("Overall GPA")
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
            }
            Group {
                if let latestcGPA = transcriptVM.transcript?.latestGPA {
                    Text("\(latestcGPA, specifier: "%.2f")/4.3")
                } else {
                    Text("No GPA Available")
                }
            }
            .padding(.vertical, 20)
            .font(.title2)
            .fontWeight(.bold)
            .multilineTextAlignment(.center)
        }
    }
    
    var body: some View {
        VStack(spacing: 10){
            titleSection
            
            VStack {
                if (transcriptVM.transcript?.courseLists == nil ||
                    (transcriptVM.transcript?.courseLists != nil && transcriptVM.transcript!.courseLists!.isEmpty) ||
                    transcriptVM.courseSortedKeys == nil) {
                    Text("No course list available")
                } else {
                    ScrollView{
                        ForEach(transcriptVM.courseSortedKeys!, id: \.self) { currentYear in
                            let currentCourses = transcriptVM.transcript!.courseLists![currentYear]
                            ForEach(semesterOrder) { currentSemeser in
                                Group {
                                    if let lists = currentCourses![currentSemeser]{
                                        VStack{
                                            HStack {
                                                Text(currentYear)
                                                    .font(.title3)
                                                Text(currentSemeser.description)
                                                    .font(.title3)
                                                Spacer()
                                                if let sGPA = transcriptVM.transcript?.GPAs?[currentYear]?[currentSemeser]?.sGPA, let cGPA = transcriptVM.transcript?.GPAs?[currentYear]?[currentSemeser]?.cGPA {
                                                    VStack(alignment: .leading){
                                                        Text("sGPA: \(sGPA, specifier: "%.2f")")
                                                        Text("cGPA: \(cGPA, specifier: "%.2f")")
                                                    }.font(.subheadline)
                                                }
                                            }
                                            ForEach(lists, id: \.code) { course in
                                                CourseRow(course: course)
                                            }
                                        }
                                    } else {
                                        EmptyView()
                                    }
                                }
                            }
                        }
                    }
                }
            }
            Spacer()
        }
        .padding(.all, 15)
        .padding(.bottom, 0)
        .navigationTitle("Transcript")
        .navigationBarTitleDisplayMode(.large)
        .toast(isPresenting: $transcriptVM.loading) {
            AlertToast(displayMode: .alert, type: .loading)
        }
        .toast(isPresenting: $transcriptVM.normalMessage.show) {
            AlertToast(displayMode: .banner(.slide), type: .error(.red), title: transcriptVM.normalMessage.title, subTitle: transcriptVM.normalMessage.subtitle)
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Refresh", systemImage: "arrow.clockwise") {
                    Task {
                        await transcriptVM.refreshTranscript()
                    }
                }.disabled(transcriptVM.loading || !PortalScraper.shared.isSignedIn)
            }
        }
    }
}

struct CourseRow: View {
    let course: Course
    
    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            ZStack {
                Group {
                    switch course.status {
                    case .taken:
                        Image(systemName: "checkmark")
                            .foregroundStyle(.accent)
                    case .inProgress:
                        Image(systemName: "clock.arrow.2.circlepath")
                            .foregroundStyle(.yellow)
                    case .toBeReleased:
                        Image(systemName: "ellipsis")
                    case .transferred:
                        Image(systemName: "arrow.backward")
                    case .unknown:
                        Image(systemName: "questionmark")
                    }
                }
                .font(.title)
                Rectangle()
                    .fill(.gray)
                    .cornerRadius(10)
                    .opacity(0.4)
            }.frame(width: 60, height: 60, alignment: .center)
            VStack(alignment: .leading) {
                Text(course.title)
                    .bold()
                    .font(.headline)
                Group {
                    if let credit = course.credit {
                        if credit == 0.0 {
                            Text("\(course.code) (No credit)")
                                .foregroundStyle(.gray)
                        } else {
                            Text("\(course.code) (\(credit, specifier: "%.2f") \(credit > 1.0 ? "CRs" : "CR"))")
                                .foregroundStyle(.gray)
                        }
                    } else {
                        Text(course.code)
                            .foregroundStyle(.gray)
                    }
                }
                .lineLimit(1)
            }
            Spacer()
            if course.status == .inProgress {
                EmptyView()
            } else {
                Spacer()
                HStack(alignment:.center) {
                    GradeText(grade: course.grade)
                }
                .frame(minWidth: 40)
            }
        }
        .padding(.trailing, 10)
        .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/)
    }
}

struct GradeText: View {
    @State private var isShowingFullDescription = false
    let grade: Grade
    
    var body: some View {
        switch grade {
        case .F:
            Text(grade.rawValue)
                .bold()
                .foregroundStyle(.red)
        case let value where value.description.count > 2 :
            Button {
                isShowingFullDescription = true
            } label: {
                HStack(spacing: 2) {
                    Text(grade.rawValue)
                        .bold()
                    Image(systemName: "questionmark.circle")
                        .font(.system(size: 8.0))
                        .baselineOffset(6.0)
                }
            }
            .popover(isPresented: $isShowingFullDescription, arrowEdge: .top) {
                Text(grade.description)
                    .padding(.horizontal)
                    .presentationCompactAdaptation((.popover))
            }
        default:
            Text(grade.rawValue)
                .bold()
        }
    }
}

#Preview {
    TranscriptView()
}
