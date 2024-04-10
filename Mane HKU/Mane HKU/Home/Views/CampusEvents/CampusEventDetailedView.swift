//
//  CampusEventDetailedView.swift
//  Mane HKU
//
//  Created by Yau Chin Pang on 10/4/2024.
//

import SwiftUI

struct CampusEventDetailedView: View {
    let event: Events_ListLatestEventsResponse.FullEventInfo
    @State var image: Image? = nil
    @State var userHasApplied = false
    @State var applyInfo: Events_ApplyInfo?
    
    var userCanApply: Bool {
        get {
            event.event.status == .open && event.participation.currentCount < event.participation.limit && !userHasApplied && applyInfo != nil
        }
    }
    
    init(event: Events_ListLatestEventsResponse.FullEventInfo) {
        self.event = event
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            ScrollView {
                if event.event.hasImagePath {
                    ImageWithBlurredText(image: image, text: event.event.title)
                        .transition(.push(from: .top))
                } else {
                    Text(event.event.title)
                        .font(.headline)
                        .bold()
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                Group {
                    if userHasApplied {
                        Label("You have applied to this event already!", systemImage: "person.crop.circle.badge.checkmark")
                            .tint(.accent)
                            .transition(.push(from: .top))
                    }
                    IconWithText(systemImage: "calendar.badge.clock", title: "Time", subtitle: ((event.event.startTime.date)..<(event.event.endTime.date)).formatted(date: .numeric, time: .shortened))
                    
                    IconWithText(systemImage: "map", title: "Location", subtitle: event.event.location)
                    
                    IconWithText(systemImage: "person.2", title: "Hosted By", subtitle: event.organizer.name)
                    
                    
                    if event.event.status == .open {
                        IconWithText(systemImage: "person.badge.plus", title: "Status", subtitle: "Open with \(event.participation.currentCount)/\(event.participation.limit) participants")
                    } else if event.event.status == .closed {
                        IconWithText(systemImage: "person.fill.xmark", title: "Status", subtitle: "Closed with \(event.participation.currentCount)/\(event.participation.limit) participants", iconColor: .pink)
                    } else {
                        IconWithText(systemImage: "person.fill.questionmark", title: "Status", subtitle: "Unavailable", iconColor: .pink)
                    }
                    
                    descriptonBody
                    
                    organizerDescription
                    
                    NavigationLink {
                        LazyView(ApplyEventView(eventID: event.event.id, applyInfo: applyInfo!))
                    } label: {
                        Label("Apply", systemImage: "person.badge.plus")
                            .tint(.primary)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(userCanApply ? .accent : .gray)
                            .clipShape(Capsule())
                    }
                    .disabled(!userCanApply)
                    
                }
                .padding(10)
                .animation(.snappy)
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
        }
        .task {
            if event.event.hasImagePath {
                if let image = await UserManager.shared.getEventImage(at: event.event.imagePath) {
                    self.image = image
                } else {
                    self.image = Image("EventPlaceholder")
                }
            }
        }
        .task {
            print("getting apply info")
            var request = Events_GetEventApplyInfoRequest()
            request.eventID = event.event.id
            do {
                let callOptions = try await GRPCServiceManager.shared.getCallOptionsWithToken()
                let unaryCall = GRPCServiceManager.shared.serviceClient.getEventApplyInfo(request, callOptions: callOptions)
                print("received apply info")
                unaryCall.response.whenComplete { result in
                    switch result {
                    case .success(let response):
                        print(response)
                        self.userHasApplied = response.userApplied
                        if response.hasApplyInfo {
                            self.applyInfo = response.applyInfo
                        }
                    case .failure(let error):
                        print(error.localizedDescription)
                    }
                }
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    var descriptonBody: some View {
        Group {
            if !event.event.description_p.isEmpty {
                let htmlString = event.event.description_p
                HStack {
                    Text("Description")
                        .font(.title2)
                        .bold()
                    Spacer()
                }
                
                Text(event.event.description_p)
                //                if let nsAttributedString = try? NSAttributedString(data: Data(htmlString.utf8), options: [.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil),
                //                   let attributedString = try? AttributedString(nsAttributedString, including: \.uiKit) {
                //                    Text(attributedString)
                //                } else {
                //
                //                }
            } else {
                Text("No description provided")
            }
        }
    }
    
    var organizerDescription: some View {
        Group {
            if event.hasOrganizer && event.organizer.hasDescription_p {
                HStack {
                    Text("About \(event.organizer.name)")
                        .font(.title2)
                        .bold()
                    Spacer()
                }
                
                Text(event.organizer.description_p)
            } else {
                EmptyView()
            }
        }
    }
}

struct IconWithText: View {
    let systemImage: String
    let title: String
    let subtitle: String
    var iconColor: Color = .accent
    var subtitleColor: Color = .secondary
    
    var body: some View{
        HStack(alignment: .center){
            ZStack(alignment: .center){
                RoundedRectangle(cornerRadius: 10)
                    .backgroundStyle(.gray)
                    .frame(width: 50, height: 50)
                Image(systemName: systemImage)
                    .foregroundStyle(iconColor)
                    .font(.title2)
            }.frame(maxWidth: 50)
            
            VStack(alignment:.leading) {
                Text(title)
                    .font(.title3)
                    .bold()
                Text(subtitle)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.body)
                    .foregroundStyle(subtitleColor)
            }
        }
    }
}

//#Preview {
//    CampusEventDetailedView()
//}
