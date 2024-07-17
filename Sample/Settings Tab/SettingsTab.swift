//
//  SettingsTab.swift
//  Sample
//
//  Created by Mick MacCallum on 4/18/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Parra
import SwiftUI

struct SettingsTab: View {
    // MARK: - Internal

    var body: some View {
        NavigationStack {
            List {
                Section {
                    NavigationLink {
                        AccountManagementView()
                    } label: {
                        UserProfileCell()
                    }
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
                    VStack(alignment: .center) {
                        PoweredByParraButton()
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                }
            }
            .navigationTitle("Profile")
        }
    }

    // MARK: - Private

    @Environment(\.parra) private var parra
    @EnvironmentObject private var parraAppInfo: ParraAppInfo
}

struct ProfileUserInfoView: View {
    let userInfo: User

    var identity: String {
        if let name = userInfo.name {
            return name
        }

        if let email = userInfo.email {
            return email
        }

        if let phoneNumber = userInfo.phoneNumber {
            return phoneNumber
        }

        return "unknown"
    }

    var body: some View {
        Text(identity)
            .font(.headline)
    }
}

#Preview {
    ParraAppPreview {
        SettingsTab()
    }
}
