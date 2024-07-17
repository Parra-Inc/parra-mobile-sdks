//
//  ProfileTab.swift
//  Sample
//
//  Created by Mick MacCallum on 4/18/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Parra
import SwiftUI

struct ProfileTab: View {
    @Environment(\.parra) var parra

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

                Section("Samples") {
                    FeedbackCell()
                    RoadmapCell()
                    ChangelogCell()
                    LatestReleaseCell()
                }

                Section("Appearance") {
                    ThemeCell()
                }

                Section {
                    ReviewAppCell()
                    ShareCell()
                    LegalInfoCell()
                }

                Section {
                    LogoutCell()
                    DeleteAccountCell()
                } header: {
                    Text("Danger Zone")
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
        ProfileTab()
    }
}
