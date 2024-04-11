//
//  CampusEventContentEditorView.swift
//  Mane HKU
//
//  Created by Yau Chin Pang on 7/4/2024.
//

import SwiftUI
import RichEditorSwiftUI

struct CampusEventContentEditorView: View {
    @ObservedObject var state: RichEditorState
    @Environment(\.colorScheme) var colorScheme
    
    
    var body: some View {
        RichEditor(state: _state)
            .padding(10)
            .if(colorScheme == .dark) { view in
                view.colorInvert()
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save", systemImage: "square.and.arrow.down.fill") {
                        let attributedText = state.attributedText
                        let htmlData = try? attributedText.data(from: .init(location: 0, length: attributedText.length),documentAttributes: [.documentType: NSAttributedString.DocumentType.html])
                        guard let htmlData = htmlData else {
                            print("nil html data")
                            return
                        }
                        let htmlString = String(data: htmlData, encoding: .utf8) ?? ""
                        print(htmlString)
                    }
                }
            }
    }
}

extension View {
    /// Applies the given transform if the given condition evaluates to `true`.
    /// - Parameters:
    ///   - condition: The condition to evaluate.
    ///   - transform: The transform to apply to the source `View`.
    /// - Returns: Either the original `View` or the modified `View` if the condition is `true`.
    @ViewBuilder func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

//
//#Preview {
//    CampusEventContentEditorView()
//}
