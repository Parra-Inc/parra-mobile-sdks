//
//  ContentView.swift
//  Sample
//
//  Created by Mick MacCallum on 2/8/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

struct SampleItemRow: View {
    let title: String
    let iconName: String

    var body: some View {
        Label(
            title: { Text(title) },
            icon: { Image(systemName: iconName) }
        )
    }
}

struct ContentView: View {
    var body: some View {
        NavigationSplitView {
            List {
                Section("Feedback") {
                    NavigationLink {
                        FeedbackFormSample()
                    } label: {
                        SampleItemRow(
                            title: "Forms",
                            iconName: "list.clipboard.fill"
                        )
                    }

                    NavigationLink {
                        FeedbackFormSample()
                    } label: {
                        SampleItemRow(
                            title: "Cards",
                            iconName: "greetingcard.fill"
                        )
                    }
                }

                Section("Releases") {
                    NavigationLink {
                        FeedbackFormSample()
                    } label: {
                        SampleItemRow(title: "Roadmap", iconName: "map.fill")
                    }
                }

                Section("Notifications") {
                    NavigationLink {
                        FeedbackFormSample()
                    } label: {
                        SampleItemRow(
                            title: "Roadmap",
                            iconName: "app.badge.fill"
                        )
                    }
                }
            }
            .navigationTitle("Parra")
            .listStyle(.automatic)
//            Form {
//                Section(header: Text("Notifications")) {
            ////                    Picker("Notify Me About", selection: $notifyMeAbout) {
            ////                        Text("Direct Messages").tag(NotifyMeAboutType.directMessages)
            ////                        Text("Mentions").tag(NotifyMeAboutType.mentions)
            ////                        Text("Anything").tag(NotifyMeAboutType.anything)
            ////                    }
            ////                    Toggle("Play notification sounds", isOn: $playNotificationSounds)
            ////                    Toggle("Send read receipts", isOn: $sendReadReceipts)
//                }
//
//            }
//            VStack {
//                Image(systemName: "globe")
//                    .imageScale(.large)
//                    .foregroundStyle(.tint)
//                Text("Hello, world!")
//            }
//            .padding()
        } detail: {
            EmptyView()
        }
    }
}

#Preview {
    ContentView()
}
