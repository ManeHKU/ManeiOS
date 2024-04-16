//
//  MessageRow.swift
//  Mane HKU
//
//  Created by Yau Chin Pang on 13/4/2024.
//

import SwiftUI
import OpenAI

struct MessageRow: View {
    let message: Message
    var body: some View {
        switch message {
        case .success(let chatCompleteMessage):
            switch chatCompleteMessage{
            case .assistant(let message):
                HStack {
                    Image(systemName: "sparkles")
                        .font(.callout)
                    Text(message.content ?? "NULL Message")
                        .multilineTextAlignment(.leading)
                    Spacer()
                }
                .foregroundStyle(.accent)
            case .user(let message):
                HStack {
                    Spacer()
                    Text(message.content.string ?? "NULL")
                        .multilineTextAlignment(.trailing)
                    Image(systemName: "person")
                        .font(.callout)
                }
                .foregroundStyle(.blueishWhite)
            default:
                EmptyView()
            }
        case .retry(let retryOpenAI):
            let message = retryOpenAI.message
            switch message {
            case .user(let userMessage):
                VStack(alignment: .trailing) {
                    HStack {
                        Text(userMessage.content.string ?? "Unknown message")
                        Image(systemName: "person")
                    }
                    Text(retryOpenAI.error)
                        .foregroundStyle(.red)
                        .multilineTextAlignment(.trailing)
                }
            default:
                Text(String(describing: retryOpenAI))
            }
        case .streaming(_):
            Text("Streaming....")
        }
    }
}

//#Preview {
//    MessageRow()
//}
