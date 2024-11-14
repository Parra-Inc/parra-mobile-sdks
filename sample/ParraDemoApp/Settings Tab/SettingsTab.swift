//
//  SettingsTab.swift
//  Parra Demo
//
//  Bootstrapped with ❤️ by Parra on 11/14/2024.
//  Copyright © 2024 Parra Inc.. All rights reserved.
//

import Parra
import SwiftUI

struct SettingsTab: View {
    @Binding var navigationPath: NavigationPath

    @Environment(\.parraAppInfo) private var parraAppInfo
    @Environment(\.parraAuthState) private var parraAuthState
    @Environment(\.parraConfiguration) private var parraConfiguration
    @Environment(\.parraTheme) private var parraTheme

    var body: some View {
        NavigationStack(path: $navigationPath) {
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

                if parraAuthState.hasUser && parraConfiguration.pushNotificationOptions.enabled {
                    Section("Settings") {
                        NotificationSettingsCell()
                    }
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
            .navigationTitle("Profile")
            .navigationDestination(for: String.self) { destination in
                if destination == DeepLink.notificationSettings.rawValue {
                    ParraUserSettingsWidget(
                        layoutId: "notifications"
                    )
                }
            }
        }
    }
}

#Preview {
    ParraAppPreview(authState: .authenticatedPreview) {
        SettingsTab(navigationPath: .constant(NavigationPath()))
    }
}

#Preview {
    ParraAppPreview(authState: .unauthenticatedPreview) {
        SettingsTab(navigationPath: .constant(NavigationPath()))
    }
}
