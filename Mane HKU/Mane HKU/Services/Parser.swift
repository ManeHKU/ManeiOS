//
//  Parser.swift
//  Mane HKU
//
//  Created by Yau Chin Pang on 25/1/2024.
//

import Foundation
import SwiftSoup

struct Parser {
    func parseInfo(html: String) -> UserInfo? {
        print("parsing info from html")
        do {
            let uid: UInt
            let doc = try SwiftSoup.parse(html)
            
            let uidString = try doc.getElementById("Z_SS_STUD_SRCH_EMPLID")?.text(trimAndNormaliseWhitespace: true)
            if let unwrappedUidString = uidString {
                uid = UInt(unwrappedUidString) ?? 0
            } else {
                uid = 0
            }
            
            let name = try doc.getElementById("PERSONAL_DATA_NAME")?.text(trimAndNormaliseWhitespace: true) ?? ""
            
            let userInfo = UserInfo(uid: uid, fullName: name)
            print("parsed user info successfully")
            return userInfo
        } catch {
            print(error)
            print("aborting parse user info function")
            return nil
        }
    }
}
