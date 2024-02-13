//
//  AlertKit.swift
//  Mane HKU
//
//  Created by Yau Chin Pang on 11/1/2024.
//

import Foundation
import AlertToast
import SwiftUI

enum ToastType {
    case error, good
}

struct ToastMessage {
    var show: Bool = false {
        didSet {
            // when the alert toast changes the show from true to false (i.e. it is shown)
            if oldValue {
                title = ""
                subtitle = nil
            }
        }
    }
    var title: String = ""
    var subtitle: String? = nil
    
    mutating func showMessage(title: String, subtitle: String) {
        self.title = title
        self.subtitle = subtitle
        self.show = true
    }
}

struct CreateToast: ViewModifier {
    var title: String
    var subtitle: String?
    var toastType: ToastType
    var trigger: Binding<Bool>
    @State var vibrate = 0

    func body(content: Content) -> some View {
        content
            .toast(isPresenting: trigger, duration: 5.0) {
                switch toastType {
                case .error:
                    AlertToast.createErrorToast(title: title, subtitle: subtitle)
                case .good:
                    AlertToast.createGoodToast(title: title, subtitle: subtitle)
                }
            }
            .onChange(of: trigger.wrappedValue) {
                if trigger.wrappedValue {
                    vibrate += 1
                }
            }
            .sensoryFeedback(toastType == .good ? .success : .error, trigger: vibrate)
    }
}
extension View {
    func errorToast(title: String, subtitle: String?, trigger: Binding<Bool>) -> some View {
        modifier(CreateToast(title: title, subtitle: subtitle, toastType: .error, trigger: trigger))
    }
    
    func goodToast(title: String, subtitle: String?, trigger: Binding<Bool>) -> some View {
        modifier(CreateToast(title: title, subtitle: subtitle, toastType: .good, trigger: trigger))
    }
}
extension AlertToast {
    static func createErrorToast(title: String, subtitle: String?) -> AlertToast {
        AlertToast(displayMode: .hud,
                   type: .error(.red),
                   title: title,
                   subTitle: subtitle)
    }
    
    static func createGoodToast(title: String, subtitle: String?) -> AlertToast {
        AlertToast(displayMode: .hud,
                   type: .complete(.accentColor),
                   title: title,
                   subTitle: subtitle)
    }
}
