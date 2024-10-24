//
//  SettingsTab.swift
//  Parra Demo
//
//  Bootstrapped with ❤️ by Parra on 08/01/2024.
//  Copyright © 2024 Parra Inc.. All rights reserved.
//

import Parra
import SwiftUI

struct SettingsTab: View {
    @Environment(\.parraAppInfo) private var parraAppInfo
    @Environment(\.parraTheme) private var parraTheme

    var body: some View {
        NavigationStack {
            List {
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

                Section("General") {
                    FeedbackCell()
                    RoadmapCell()
                    ChangelogCell()
                    LatestReleaseCell()
                }

                if parraAppInfo.legal.hasDocuments {
                    Section("Legal") {
                        ForEach(parraAppInfo.legal.policyDocuments) { document in
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

                Section {
                    FeedCell()
                    StorefrontCell()
                } header: {
                    Label {
                        Text("Experimental Features")
                    } icon: {
                        Image(systemName: "flask")
                    }
                } footer: {
                    SettingsFooter()
                }
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
