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
    @EnvironmentObject private var appInfo: ParraAppInfo

    var body: some View {
        NavigationStack {
            List {
                Section {
                    ProfileCell()
                }

                Section("Appearance") {
                    ThemeCell()
                }

                Section("General") {
                    FeedbackCell()
                    RoadmapCell()
                    ChangelogCell()
                    LatestReleaseCell()
                }

                Section("Legal") {
                    ForEach(appInfo.legal.allDocuments) { document in
                        NavigationLink {
                            ParraLegalDocumentView(legalDocument: document)
                        } label: {
                            Text(document.title)
                        }
                        .id(document.id)
                    }
                }

                Section {
                    ReviewAppCell()
                    ShareCell()
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
