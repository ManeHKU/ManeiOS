//
//  CourseReviewListsView.swift
//  Mane HKU
//
//  Created by Yau Chin Pang on 30/3/2024.
//

import SwiftUI

struct CourseReviewListsView: View {
    @Bindable private var listVM = CourseReviewListViewModel()
    @State private var searchText = ""
    
    var body: some View {
        VStack {
            List {
                ForEach(listVM.coursesDisplayed, id: \.courseCode) { item in
                    NavigationLink(value: item.courseCode) {
                        ListItemView(item: item)
                    }
                }
                if listVM.moreResults {
                    lastRowView
                }
            }
            .navigationDestination(for: String.self, destination: CourseReviewDetailView.init)
        }
        .navigationTitle("Course Reviews")
        .navigationBarTitleDisplayMode(.large)
        .searchable(text: $searchText, prompt: "Enter course code or title")
        .onSubmit(of: .search) {
            Task {
                await listVM.searchCourses(query: searchText, lastCode: nil)
            }
        }.onChange(of: searchText, initial: false) { oldText, newText in
            if newText.isEmpty && !oldText.isEmpty {
                Task {
                    await listVM.defaultListCourses()
                }
            }
        }
    }
    
    var lastRowView: some View {
        ZStack(alignment: .center) {
            if listVM.loading {
                Text("Loading...")
            }
        }
        .frame(height: 50)
        .onAppear {
            Task {
                if !searchText.isEmpty {
                    await listVM.searchCourses(query: searchText, lastCode: listVM.coursesDisplayed.last?.courseCode)
                } else {
                    await listVM.listCourses(pageSize: nil, lastCode: listVM.coursesDisplayed.last?.courseCode)
                }
            }
        }
    }
}

struct ListItemView: View {
    let item: Courses_Course
    var body: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading,  spacing: 5) {
                Text(item.courseCode)
                    .bold()
                Text(item.title)
            }
            Spacer()
            Group {
                if item.offered {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                        Text("Offered")
                    }.foregroundStyle(.accent)
                } else {
                    HStack {
                        Image(systemName: "xmark.circle.fill")
                        Text("Not offered")
                    }.foregroundStyle(.pink)
                }
            }
        }
    }
}

#Preview {
    CourseReviewListsView()
}
