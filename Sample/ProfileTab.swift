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

                Section("Appearance") {
                    ThemeCell()
                }

                Section {
                    ReviewAppCell()
                    ShareCell()
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

struct ThemeCell: View {
    // MARK: - Internal

    var body: some View {
        Text(
            "Choose if \(parraAppInfo.application.name)'s appearance should be light or dark, or follow your device's settings."
        )

        Picker("Theme", selection: $themeObserver.preferredAppearance) {
            ForEach(ParraAppearance.allCases) { option in
                Text(option.description).tag(option)
            }
        }
    }

    // MARK: - Private

    @EnvironmentObject private var themeObserver: ParraThemeObserver
    @EnvironmentObject private var parraAppInfo: ParraAppInfo
    @Environment(\.parra) private var parra
}

struct ShareCell: View {
    // MARK: - Internal

    var body: some View {
        if let appStoreUrl = parraAppInfo.application.appStoreUrl {
            ShareLink(
                item: appStoreUrl,
                message: Text(
                    "Check out this awesome new app that I'm building using Parra!"
                )
            )
            .foregroundStyle(.blue)
        }
    }

    // MARK: - Private

    @EnvironmentObject private var parraAppInfo: ParraAppInfo
}

struct ReviewAppCell: View {
    // MARK: - Internal

    var body: some View {
        if let writeReviewUrl = parraAppInfo.application
            .appStoreWriteReviewUrl
        {
            Link(
                destination: writeReviewUrl
            ) {
                Label(
                    title: { Text("Review") },
                    icon: { Image(systemName: "star") }
                )
            }
        }
    }

    // MARK: - Private

    @EnvironmentObject private var parraAppInfo: ParraAppInfo
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

#Preview {
    ParraAppPreview {
        ProfileTab()
    }
}
