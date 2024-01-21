//
//  HomeViewModel.swift
//  Mane HKU
//
//  Created by Yau Chin Pang on 21/1/2024.
//

import Foundation

@Observable class HomeViewModel {
    var userInfo: UserInfo?
    
    init() {
        portalScraper.resetSession()
    }
    
    func initialLoginToSIS(using userManager: UserManager) async {
        guard let portalId = KeychainManager.shared.secureGet(key: .PortalId),
              let password = KeychainManager.shared.secureGet(key: .PortalPassword) else {
            print("Portal id or password doesn't exist")
            return
        }
        let signedIn = await portalScraper.signInSIS(portalId: portalId, password: password)
        
        if userManager.isAuthenticated && signedIn {
            self.userInfo = await portalScraper.getUserInfo()
        }
    }
}
