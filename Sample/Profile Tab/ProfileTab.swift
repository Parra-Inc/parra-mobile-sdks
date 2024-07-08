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

#Preview {
    ParraAppPreview {
        ProfileTab()
    }
}
