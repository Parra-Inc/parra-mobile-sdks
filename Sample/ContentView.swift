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
                        FeedbackFormByIdSample()
                    } label: {
                        SampleItemRow(
                            title: "Cards",
                            iconName: "greetingcard"
                        )
                    }
                }

                Section("Feedback Forms") {
                    NavigationLink {
                        FeedbackFormByIdSample()
                    } label: {
                        SampleItemRow(
                            title: "Forms by ID",
                            iconName: "list.clipboard"
                        )
                    }

                    NavigationLink {
                        FeedbackFormCustomLoadingSample()
                    } label: {
                        SampleItemRow(
                            title: "Forms with custom loader",
                            iconName: "list.bullet.clipboard"
                        )
                    }
                }

                Section("Roadmap") {
                    NavigationLink {
                        RoadmapSample()
                    } label: {
                        SampleItemRow(title: "Roadmap", iconName: "map")
                    }
                }

                Section("Releases") {
                    NavigationLink {
                        ChangelogSample()
                    } label: {
                        SampleItemRow(
                            title: "Changelog",
                            iconName: "note.text"
                        )
                    }

                    NavigationLink {
                        LatestReleaseSample()
                    } label: {
                        SampleItemRow(
                            title: "What's new?",
                            iconName: "megaphone"
                        )
                    }
                }

//                Section("Notifications") {
//                    NavigationLink {
//                        FeedbackFormByIdSample()
//                    } label: {
//                        SampleItemRow(
//                            title: "Roadmap",
//                            iconName: "app.badge"
//                        )
//                    }
//                }
            }
            .navigationTitle("Parra")
            .listStyle(.automatic)
        } detail: {
            EmptyView()
        }
    }
}

#Preview {
    ContentView()
}
