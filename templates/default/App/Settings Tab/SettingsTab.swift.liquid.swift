//
//  SettingsTab.swift.liquid.swift
//  {{ app.name }}
//
//  Bootstrapped with ❤️ by Parra on {{ "now" | date: "%m/%d/%Y" }}.
//  Copyright © {{ "now" | date: "%Y" }} {{ tenant.name }}. All rights reserved.
//

import Parra
import SwiftUI

struct SettingsTab: View {
    // MARK: - Internal

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

    // MARK: - Private

    @Environment(\.parra) private var parra
    @EnvironmentObject private var parraAppInfo: ParraAppInfo
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
