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
    let retryQuery: (_ retryObject: RetryOpenAI) -> Void
    var body: some View {
        switch message {
        case .success(let chatCompleteMessage):
            switch chatCompleteMessage{
            case .assistant(let message):
                if message.toolCalls == nil || message.toolCalls!.isEmpty {
                    HStack {
                        Image(systemName: "sparkles")
                            .font(.callout)
                        Text(try! AttributedString(markdown: message.content ?? "EMPTY MESSAGE", options:  AttributedString.MarkdownParsingOptions(interpretedSyntax: .inlineOnlyPreservingWhitespace)))
                            .multilineTextAlignment(.leading)
                        Spacer()
                    }
                    .foregroundStyle(.accent)
                }
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
                    Text(retryOpenAI.error.capitalized)
                        .foregroundStyle(.red)
                        .multilineTextAlignment(.trailing)
                    Button("Retry", systemImage: "arrow.clockwise") {
                        retryQuery(retryOpenAI)
                    }
                }
            default:
                Text(String(describing: retryOpenAI))
            }
        case .streaming(_):
            Text("Streaming....")
        case .error(let error):
            VStack(alignment: .center) {
                HStack {
                    Text(error.message.content?.string ?? "Unknown message")
                    Image(systemName: "person")
                }
                Text(error.errorString.capitalized)
                    .foregroundStyle(.red)
                    .multilineTextAlignment(.trailing)
            }
        }
    }
}

//#Preview {
//    MessageRow()
//}
