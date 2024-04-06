//
//  AlertToastManager.swift
//  Mane HKU
//
//  Created by Yau Chin Pang on 5/4/2024.
//

import Foundation
import AlertToast

@Observable class AlertToastManager {
    var show = false
    var alertToast = AlertToast(type: .regular, title: "SOME TITLE"){
        didSet{
            show.toggle()
        }
    }
    
    var showLoading = false
    var loadingToast = AlertToast(displayMode: .alert, type: .loading)
}
