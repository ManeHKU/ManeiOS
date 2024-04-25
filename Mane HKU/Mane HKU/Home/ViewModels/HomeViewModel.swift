//
//  HomeViewModel.swift
//  Mane HKU
//
//  Created by Yau Chin Pang on 21/1/2024.
//

import Foundation
import SwiftProtobuf

@Observable class HomeViewModel {
    var userInfo: UserInfo? {
        didSet {
            if let encoded = try? JSONEncoder().encode(userInfo) {
                print("updating local userinfo default")
                UserDefaults.standard.setValue(encoded, forKey: UserDefaults.DefaultKey.userInfo.rawValue)
            }
        }
    }
    var loading = false
    var nickname: String {
        let defaults = UserDefaults.standard
        return defaults.string(forKey: UserDefaults.DefaultKey.nickname.rawValue) ?? ""
    }
    var successMessage: ToastMessage = ToastMessage()
    var errorMessage: ToastMessage = ToastMessage()
    
    init() {
        Task {
            await self.initalise()
        }
    }
    
    private func initalise() async {
        defer {
            loading = false
        }
        let loginResult = Task(priority: .userInitiated) { () -> Bool in
            PortalScraper.shared.resetSession()
            guard let portalId = KeychainManager.shared.secureGet(key: .PortalId) else {
                print("Portal id doesn't exist")
                return false
            }
            let signedIn = await PortalScraper.shared.fastSISLogin(portalId: portalId, relogin: true)
            if !signedIn {
                self.errorMessage.showMessage(title: "Error", subtitle: "Please try again later")
            }
            return signedIn
        }
        loading = true
        let defaults = UserDefaults.standard
        if defaults.isKeyPresent(key: .userInfo) {
            print("user default present")
            if let data = defaults.data(forKey: UserDefaults.DefaultKey.userInfo.rawValue) {
                print("Got the user default")
                userInfo = try? JSONDecoder().decode(UserInfo.self, from: data)
                return
            }
        }
        print("user default not present")
        do {
            let result = try await loginResult.result.get()
            let isAuth = await UserManager.shared.isAuthenticated
            if result && isAuth {
                self.userInfo = await PortalScraper.shared.getUserInfo()
                await updateUserInfo()
                return
            }
        } catch {
            print("Unknown error.")
        }
        print("signing out...")
        try? await UserManager.shared.supabase.auth.signOut()
    }
    
    func updateUserInfo() async {
        guard let unwrappedInfo = userInfo else {
            return
        }
        print("Building request")
        var request = Service_UpdateUserInfoRequest()
        request.uid = UInt32(unwrappedInfo.uid)
        request.fullName = unwrappedInfo.fullName
        
        print("Calling service func")
        do {
            let callOptions = try await GRPCServiceManager.shared.getCallOptionsWithToken()
            print("recevied token")
            let unaryCall = GRPCServiceManager.shared.serviceClient.updateUserInfo(request, callOptions: callOptions)
            let statusCode = try await unaryCall.status.get()
            _ = try await unaryCall.response.get()
            print("received results, with status \(statusCode)")
            self.successMessage.showMessage(title: "Success", subtitle: "Updated User Info")
        } catch {
            print(error.localizedDescription)
            self.errorMessage.showMessage(title: "Error", subtitle: "Please try again later")
        }
    }
}
