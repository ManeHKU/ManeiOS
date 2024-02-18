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
    
    var body: some View {
        VStack(spacing: 10){
            VStack() {
                HStack{
                    Text("Overall GPA")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.vertical, 20)
                    Spacer()
                }
                if transcriptVM.transcript?.latestGPA != nil {
                    Text(String(transcriptVM.transcript!.latestGPA!))
                        .font(.title3)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                } else {
                    Text("No GPA Available")
                        .font(.title3)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                }
            }
            VStack {
                HStack{
                    Text("Fall 2020")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.vertical, 20)
                    Spacer()
                }
                if transcriptVM.loading {
                    
                } else {
                    if ((transcriptVM.transcript?.courseLists) != nil && transcriptVM.transcript!.courseLists!.isEmpty) {
                        Text("No course list available")
                    }
                    if transcriptVM.transcript?.latestGPA != nil {
                        Text(String(transcriptVM.transcript!.latestGPA!))
                            .font(.title3)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                    } else {
                        Text("No GPA Available")
                            .font(.title3)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                    }
                }
            }
            Spacer()
        }
        .padding(.all, 15)
        .navigationTitle("Transcript")
        .navigationBarTitleDisplayMode(.large)
        .toast(isPresenting: $transcriptVM.loading) {
            AlertToast(displayMode: .alert, type: .loading)
        }
    }
}

#Preview {
    TranscriptView()
}
