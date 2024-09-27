//
//  SettingsTab.swift
//  Parra Demo
//
//  Bootstrapped with ❤️ by Parra on 09/27/2024.
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

                Section("Appearance") {
                    ThemeCell()
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
                } footer: {
                    SettingsFooter()
                }
            }
            .background(parraTheme.palette.primaryBackground)
            .scrollContentBackground(.hidden)
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
