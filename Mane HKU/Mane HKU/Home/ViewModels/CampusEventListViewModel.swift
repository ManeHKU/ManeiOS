//
//  CampusEventListViewModel.swift
//  Mane HKU
//
//  Created by Yau Chin Pang on 10/4/2024.
//

import Foundation
import GRPC

enum sortDirection {
    case ASC, DESC
}

@Observable class CampusEventListViewModel {
    private var serviceClient = GRPCServiceManager.shared.serviceClient!
    var displayedEvents: [Events_ListLatestEventsResponse.FullEventInfo] {
        get {
            if direction == .ASC {
                return _events
            } else {
                return _events.reversed()
            }
        }
    }
    private var _events: [Events_ListLatestEventsResponse.FullEventInfo] = [] {
        didSet {
            print(_events)
        }
    }
    var loading = false
    var sortBy: Events_SortBy = .createdAt {
        didSet {
            if oldValue != sortBy {
                Task {
                    await fetchEvents()
                }
            }
        }
    }
    var direction: sortDirection = .ASC
    var errorMessage = ToastMessage()
    var normalMessage = ToastMessage()
    
    init() {
        Task {
            loading = true
            await fetchEvents()
            loading = false
        }
    }
    
    func fetchEvents() async {
        print("fetching campus events")
        var request = Events_ListLatestEventsRequest()
        request.sortBy = self.sortBy
        do {
            loading = true
            let callOptions = try await GRPCServiceManager.shared.getCallOptionsWithToken()
            let unaryCall = serviceClient.listLatestEvents(request, callOptions: callOptions)
            print("received campus events")
            unaryCall.response.whenComplete { result in
                switch result {
                case .success(let response):
                    if response.hasErrorMessage {
                        self.errorMessage.showMessage(title: "Error!", subtitle: response.errorMessage.capitalized)
                    } else {
                        self.__events = response.events
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                    if let status = error as? GRPCStatus {
                        if status.code == .unauthenticated {
                            Task {
                                try? await UserManager.shared.supabase.auth.refreshSession()
                                self.normalMessage.showMessage(title: "Unauthorized action", subtitle: "Please try again later")
                            }
                        } else if status.code == .invalidArgument || status.code == .aborted {
                            self.errorMessage.showMessage(title: "Unknown error", subtitle: "Please try again later")
                        }
                    } else {
                        self.errorMessage.showMessage(title: "Unknown error", subtitle: error.localizedDescription)
                    }
                }
                self.loading = false
            }
        } catch (UserManagerError.notAuthenticated) {
            print("unauthorized")
            errorMessage.showMessage(title: "Unauthroized action", subtitle: "Please login again")
            loading = false
        } catch {
            print(error.localizedDescription)
            loading = false
        }
    }
}
