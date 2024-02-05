//
//  UserDefault.swift
//  Mane HKU
//
//  Created by Yau Chin Pang on 25/1/2024.
//

import Foundation

extension UserDefaults {
    enum DefaultKey: String {
        case userInfo = "user-info"
        case nickname = "nickname"
    }
    
    func isKeyPresent(key: DefaultKey) -> Bool {
        return UserDefaults.standard.object(forKey: key.rawValue) != nil
    }
}
