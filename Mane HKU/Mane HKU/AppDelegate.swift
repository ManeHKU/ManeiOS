//
//  AppDelegate.swift
//  Mane HKU
//
//  Created by Yau Chin Pang on 26/2/2024.
//

import Foundation
import UIKit

class AppDelegate: NSObject, UIApplicationDelegate {
    func applicationWillTerminate(_ application: UIApplication) {
        CookieHandler.shared.backupAllCookies()
    }
}
