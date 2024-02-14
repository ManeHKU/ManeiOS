//
//  AppRootManager.swift
//  Mane HKU
//
//  Created by Yau Chin Pang on 14/2/2024.
//

import Foundation

@Observable
class AppRootManager: ObservableObject {
    
    var currentRoot: eAppRoots = .splash
    
    enum eAppRoots {
        case splash
        case authentication
        case home
    }
}
