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
                    ForEach(parraAppInfo.legal.allDocuments) { document in
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
