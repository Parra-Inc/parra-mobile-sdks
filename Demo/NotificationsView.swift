//
//  NotificationsView.swift
//  Demo
//
//  Created by Ian MacCallum on 5/17/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import SwiftUI
import SwiftUI

struct Notification: Identifiable {
    enum Image {
        case emoji(String)
        case image(String)
        case placeholder
    }
    
    enum `Type` {
        case text
        case friendRequest
    }
    let id = UUID()
    let title: String
    let message: String
    let image: Image
    let type: `Type`
}

struct NotificationsView: View {
    let notifications: [Notification] = [
        Notification(title: "Welcome!", message: "Thank you for choosing Parra! We hope you enjoy and please let us know how we can improve!", image: .emoji("🎉"), type: .text),
        Notification(title: "Friend Request", message: "You have a new friend request", image: .placeholder, type: .friendRequest),
    ]
    
    var body: some View {
        NavigationView {
            List(notifications) { notification in
                NotificationRow(notification: notification)
            }
//            .listStyle(GroupedListStyle()) // or PlainListStyle()
            .navigationTitle("Notifications")

        }
    }
}

struct NotificationRow: View {
    let notification: Notification
    
    var body: some View {
        HStack(alignment: .top) {
            switch notification.image {
            case .emoji(let emoji):
                Text(emoji)
                    .frame(width: 24, height: 24)
            case .image(let imageName):
                Image(systemName: imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 24, height: 24)
            case .placeholder:
                ZStack {
                    Circle()
                        .frame(width: 24, height: 24)
                        .foregroundColor(Color(uiColor: UIColor(hex: 0xFAFAFA)))
                    Image(systemName: "person.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 14, height: 14)
                        .foregroundColor(Color(uiColor: UIColor(hex: 0xC4C4C4)))
                }
            }
            
            VStack(alignment: .leading) {
                Text(notification.title)
                    .font(.headline)
                    .padding(.bottom, 2)
                Text(notification.message)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding(.bottom, 2)

                switch notification.type {
                case .text:
                    HStack {}
                case .friendRequest:
                    HStack {
                        Button(action: {
                            print("Reject")
                        }) {
                            Text("Reject")
                                .frame(minWidth: 0, maxWidth: .infinity)
                                .font(.system(size: 12))
                                .padding(EdgeInsets(top: 6, leading: 10, bottom: 6, trailing: 10))
                                .foregroundColor(.red)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.white, lineWidth: 2)
                            )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.red, lineWidth: 2)
                                )
                        }
                        .cornerRadius(8)

                        Button(action: {
                            print("Accept")
                        }) {
                            Text("Accept")
                                .frame(minWidth: 0, maxWidth: .infinity)
                                .font(.system(size: 12))
                                .padding(EdgeInsets(top: 6, leading: 10, bottom: 6, trailing: 10))
                                .foregroundColor(.white)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.white, lineWidth: 2)
                            )
                        }
                        .background(Color(uiColor: .init(hex: 0x32ade6)))
                        .cornerRadius(8)
                    }
                }
            }
            .padding(.leading, 8)
        }
        .padding(.top, 6)
    }
}

struct NotificationsView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationsView()
    }
}
