//
//  UserInfo.swift
//  Mane HKU
//
//  Created by Yau Chin Pang on 21/1/2024.
//

import Foundation

struct UserInfo: Codable, Equatable {
    var uid: UInt
    var fullName: String
    
    static func == (lhs: UserInfo, rhs: UserInfo) -> Bool {
        lhs.uid == rhs.uid && lhs.fullName == rhs.fullName
    }
}
