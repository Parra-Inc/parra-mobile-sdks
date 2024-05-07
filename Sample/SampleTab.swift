//
//  SampleTab.swift
//  Sample
//
//  Created by Mick MacCallum on 4/18/24.
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

struct SampleTab: View {
    var body: some View {
        NavigationSplitView {
            List {
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
    SampleTab()
}
