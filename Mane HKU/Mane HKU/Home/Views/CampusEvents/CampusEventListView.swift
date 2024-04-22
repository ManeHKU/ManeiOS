//
//  CampusEventListView.swift
//  Mane HKU
//
//  Created by Yau Chin Pang on 10/4/2024.
//

import SwiftUI
import AlertToast

struct CampusEventListView: View {
    @Environment(AlertToastManager.self) private var alertToast: AlertToastManager
    @Bindable private var listVM = CampusEventListViewModel()
    @State private var goToAddEvent = false
    var body: some View {
        VStack {
            Menu("Sort By", systemImage: "line.3.horizontal.decrease") {
                Menu("Event Creation Time") {
                    Button("Nearest First") {
                        listVM.sortBy = .createdAt
                        listVM.direction = .DESC
                    }
                    Button("Furthest First") {
                        listVM.sortBy = .createdAt
                        listVM.direction = .ASC
                    }
                }
                Menu("Event Starting Time") {
                    Button("Nearest First") {
                        listVM.sortBy = .participationTime
                        listVM.direction = .ASC
                    }
                    Button("Furthest First") {
                        listVM.sortBy = .participationTime
                        listVM.direction = .DESC
                    }
                }
            }
            .padding()
            .background(.ultraThinMaterial)
            .clipShape(.capsule)
            .padding(.top, 10)
            List {
                ForEach(listVM.displayedEvents, id: \.event.id) { event in
                    NavigationLink(value: event) {
                        CampusEventRow(event: event)
                    }
                }
            }
            .navigationDestination(for: Events_ListLatestEventsResponse.FullEventInfo.self, destination: CampusEventDetailedView.init)
            Spacer()
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Add Event", systemImage: "calendar.badge.plus") {
                    Task {
                        await listVM.fetchUserOrganizationAdmin {
                            goToAddEvent.toggle()
                        }
                    }
                }
                .disabled(listVM.loading || (listVM.userIsAdminOfOrganizations?.isEmpty ?? false))
            }
        }
        .onChange(of: listVM.userIsAdminOfOrganizations) {
            if let adminList = listVM.userIsAdminOfOrganizations {
                if adminList.isEmpty {
                    alertToast.alertToast = AlertToast(displayMode: .hud, type: .error(.red), title: "Unauthorized!", subTitle: "You are not admin of any organizations!")
                }
            }
        }
        .navigationDestination(isPresented: $goToAddEvent) {
            LazyView(AddEventView(orgs: listVM.userIsAdminOfOrganizations!))
        }
        .onChange(of: listVM.loading, initial: true) {
            alertToast.showLoading = listVM.loading
        }
        .navigationTitle("Campus Events")
        .navigationBarTitleDisplayMode(.large)
    }
    
    struct CampusEventRow: View {
        let event: Events_ListLatestEventsResponse.FullEventInfo
        var hasImagePath: Bool {
            get {
                event.event.hasImagePath
            }
        }
        var eventStatus : String {
            get {
                switch event.event.status {
                case .open:
                    "Open"
                case .closed:
                    "Closed"
                case .unavailable:
                    "Unavailable"
                case .UNRECOGNIZED(_):
                    "Unkown"
                }
            }
        }
        @State var eventImage: Image? = nil
        @State var loadingImage: Bool = true
        
        init(event: Events_ListLatestEventsResponse.FullEventInfo) {
            self.event = event
            loadingImage = hasImagePath
        }
        var body: some View {
            HStack(alignment: .center) {
                if event.hasEvent {
                    VStack(alignment: .leading, spacing: 5) {
                        Text(event.event.title)
                            .bold()
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text("Hosted by \(event.organizer.name)")
                            .font(.subheadline)
                        Text(((event.event.startTime.date)..<(event.event.endTime.date)).formatted(date: .abbreviated, time: .shortened))
                            .foregroundStyle(.secondary)
                            .font(.caption)
                        Text("\(eventStatus)" + (event.event.status == .open ? " \(event.participation.currentCount)/\(event.participation.limit)" : ""))
                            .font(.caption)
                            .foregroundStyle(event.event.status == .open ? .accent : .pink)
                    }
                    if hasImagePath {
                        Group {
                            if loadingImage {
                                ProgressView()
                            } else if let image = eventImage {
                                image
                                    .resizable()
                            } else {
                                Image(systemName: "questionmark.app.dashed")
                                    .resizable()
                            }
                        }
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .clipShape(.rect(cornerRadius: 20))
                    }
                } else {
                    Text("No event found. Error!")
                }
            }
            .frame(maxWidth: .infinity)
            .task {
                if event.event.hasImagePath {
                    loadingImage = true
                    Task {
                        eventImage = await UserManager.shared.getEventImage(at: event.event.imagePath)
                        loadingImage = false
                    }
                }
            }
        }
    }
}



#Preview {
    CampusEventListView()
}
