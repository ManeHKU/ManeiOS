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
                ScrollView {
                    VStack(spacing: 10) {
                        ForEach(gptVM.messages, id: \.id) { message in
                            MessageRow(message: message)
                        }
                    }
                }
                .onTapGesture {
                    isTextFieldFocused = false
                }
                HStack(alignment: .center) {
                    TextField("Send message", text: $gptVM.inputMessage, axis: .vertical)
                        .textFieldStyle(.roundedBorder)
                        .focused($isTextFieldFocused)
                    Button {
                        Task { @MainActor in
                            isTextFieldFocused = false
                            //                            scrollToBottom(proxy: proxy)
                            gptVM.sendMessage()
                        }
                    } label: {
                        Image(systemName: "paperplane.circle.fill")
                            .rotationEffect(.degrees(45))
                            .font(.system(size: 30))
                    }
                    .disabled(gptVM.openAILoading || gptVM.inputMessage.isEmpty)
                }.frame(maxWidth: .infinity)
            }
        }
        .padding(10)
    }
}

#Preview {
    GPTView()
}
