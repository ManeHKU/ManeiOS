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
    
    var showBanner = false
    var bannerToast = AlertToast(displayMode: .banner(.slide), type: .regular, title: "SOME TITLE"){
        didSet{
            showBanner.toggle()
        }
    }
    
    var showLoading = false
    let loadingToast = AlertToast(displayMode: .alert, type: .loading)
}
