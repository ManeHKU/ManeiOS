//
//  CourseReviewDetailView.swift
//  Mane HKU
//
//  Created by Yau Chin Pang on 1/4/2024.
//

import SwiftUI

struct CourseReviewDetailView: View {
    let courseCode: String
    @Bindable private var detailVM: CourseReviewDetailViewModel
    init(courseCode: String) {
        self.courseCode = courseCode
        self.detailVM = CourseReviewDetailViewModel(courseCode: courseCode)
    }
    
    var body: some View {
        VStack(alignment: .leading){
            if !detailVM.loading {
                if let courseDetail = detailVM.courseDetail{
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
                                Text("Offered in current academic year")
                            }.foregroundStyle(.accent)
                        } else {
                            HStack {
                                Image(systemName: "xmark.circle.fill")
                                Text("Not offered in current academic year")
                            }.foregroundStyle(.pink)
                        }
                        Text("Offered by \(courseDetail.department)")
                            .font(.headline)
                        if courseDetail.description_p.isEmpty {
                            Text("No description")
                        } else {
                            ExpandableText(courseDetail.description_p, lineLimit: 5)
                        }
                        Spacer()
                    }
                    .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .topLeading)
                } else {
                    Text("Unable to find \(courseCode)")
                        .font(.callout)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .navigationTitle(courseCode)
        .navigationBarTitleDisplayMode(.large)
        .padding(.all, 15)
    }
    
    
}

#Preview {
    CourseReviewDetailView(courseCode: "COMP3330")
}
