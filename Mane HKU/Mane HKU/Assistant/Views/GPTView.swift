//
//  GPTView.swift
//  Mane HKU
//
//  Created by Yau Chin Pang on 12/4/2024.
//

import SwiftUI
import OpenAI

struct GPTView: View {
    @Bindable private var gptVM = GPTViewModel()
    @FocusState private var isTextFieldFocused
    var openAI: OpenAI? {
        get {
            gptVM.openAI
        }
    }
    
    var body: some View {
        VStack {
            if let err = gptVM.error {
                Text(err)
            }
            if let openAI {
                Spacer()
                ScrollViewReader { proxy in
                    ScrollView {
                        VStack(spacing: 10) {
                            ForEach(gptVM.messages, id: \.id) { message in
                                MessageRow(message: message, retryQuery: gptVM.retryQuery)
                                    .id(message.id)
                            }
                        }
                    }
                    .onChange(of: gptVM.messages.count) { @MainActor in
                        withAnimation {
                            proxy.scrollTo(gptVM.messages.last!.id, anchor: .bottom)
                        }
                    }
                }
                .onTapGesture {
                    isTextFieldFocused = false
                }
                if gptVM.retrievingInfo {
                    HStack(alignment: .center, spacing: 5) {
                        ProgressView()
                        Text("Retrieving extra info to assistant...")
                            .foregroundStyle(.secondary)
                    }
                    .font(.footnote)
                }
                HStack(alignment: .center) {
                    TextField("Send message", text: $gptVM.inputMessage, axis: .vertical)
                        .textFieldStyle(.roundedBorder)
                        .focused($isTextFieldFocused)
                    Button {
                        Task { @MainActor in
                            isTextFieldFocused = false
                            gptVM.sendMessageFromUser()
                        }
                    } label: {
                        Group {
                            if gptVM.openAILoading {
                                ProgressView()
                                    .tint(.accent)
                                    .padding(.horizontal, 5)
                            } else {
                                Image(systemName: "paperplane.circle.fill")
                            }
                        }
                        .font(.system(size: 30))
                    }
                    .disabled(gptVM.openAILoading || gptVM.inputMessage.isEmpty || gptVM.stopMessage)
                }.frame(maxWidth: .infinity)
            }
        }
        .padding(10)
    }
}

#Preview {
    GPTView()
}
