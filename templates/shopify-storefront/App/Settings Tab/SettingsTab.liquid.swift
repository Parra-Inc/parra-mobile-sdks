//
//  SettingsTab.swift
//  {{ app.name.raw }}
//
//  Bootstrapped with ❤️ by Parra on {{ "now" | date: "%m/%d/%Y" }}.
//  Copyright © {{ "now" | date: "%Y" }} {{ tenant.name }}. All rights reserved.
//

import Parra
import SwiftUI

struct SettingsTab: View {
    @Environment(\.parraAppInfo) private var parraAppInfo
    @Environment(\.parraTheme) private var parraTheme

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    ProfileCell()
                }

                // The appearance picker should only be shown in your app
                // supports light/dark mode. To enable this, define a dark color
                // palette when you instantiate your ParraTheme instance.
                if parraTheme.supportsMultipleColorPalettes {
                    Section("Appearance") {
                        ThemeCell()
                    }
                }

                Section("Store") {
                    StorefrontCell()
                }

                Section("General") {
                    FeedbackCell()
                    RoadmapCell()
                    ChangelogCell()
                    LatestReleaseCell()
                }

                if parraAppInfo.legal.hasDocuments {
                    Section("Legal") {
                        ForEach(parraAppInfo.legal.allDocuments) { document in
                            NavigationLink {
                                ParraLegalDocumentView(legalDocument: document)
                            } label: {
                                Text(document.title)
                            }
                            .id(document.id)
                        }
                    }
                }

                Section {
                    ReviewAppCell()
                    ShareCell()
                }

                SettingsFooter()
                    .frame(
                        height: 24
                    )
                    .listRowBackground(EmptyView())

            }
            .navigationTitle("Profile")
        }
    }
}

#Preview {
    ParraAppPreview(authState: .authenticatedPreview) {
        SettingsTab()
    }
}

#Preview {
    ParraAppPreview(authState: .unauthenticatedPreview) {
        SettingsTab()
    }
}
