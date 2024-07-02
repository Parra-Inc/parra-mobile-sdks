//
//  ProfileTab.swift
//  Sample
//
//  Created by Mick MacCallum on 4/18/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Parra
import StoreKit
import SwiftUI

struct ProfileTab: View {
    @Environment(\.parra) var parra

    var body: some View {
        NavigationStack {
            List {
                Section {
                    VStack(alignment: .center, spacing: 12) {
                        ParraProfilePhotoWell()

                        if let userInfo = parra.user?.userInfo {
                            ProfileUserInfoView(userInfo: userInfo)
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                }

                Section {
                    // logout
                    // delete account
                    // share
                    // rate
                    ReviewAppCell()
                    LegalInfoCell()
                }

                Section("Danger Zone") {
                    LogoutCell()
                    DeleteAccountCell()
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

struct LegalInfoCell: View {
    var body: some View {
        NavigationLink {
            ParraLegalInfoView()
        } label: {
            Label(
                title: { Text("Legal") },
                icon: { Image(systemName: "doc.text") }
            )
        }
        .foregroundStyle(.blue)
    }
}

struct LogoutCell: View {
    @Environment(\.parra) var parra

    var body: some View {
        Button(action: {
            parra.auth.logout()
        }) {
            Label(
                title: { Text("Logout") },
                icon: {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                }
            )
        }
    }
}

struct DeleteAccountCell: View {
    @Environment(\.parra) var parra

    var body: some View {
        Button(action: {
            parra.auth.deleteAccount()
        }) {
            Label(
                title: { Text("Delete account") },
                icon: {
                    Image(systemName: "trash.circle")
                }
            )
        }
    }
}

struct ReviewAppCell: View {
    // MARK: - Internal

    var body: some View {
        if let appId = parraAppInfo.application.appId {
            Link(
                destination: URL(
                    string: "https://apps.apple.com/app/id\(appId)?action=write-review"
                )!
            ) {
                Label(
                    title: { Text("Rate") },
                    icon: { Image(systemName: "star") }
                )
            }
        } else {
            EmptyView()
        }
    }

    // MARK: - Private

    @EnvironmentObject private var parraAppInfo: ParraAppInfo
}

#Preview {
    ParraAppPreview {
        ProfileTab()
    }
}
