//
//  AccountView.swift
//  Sample
//
//  Created by Mick MacCallum on 7/17/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Parra
import SwiftUI

struct AccountView: View {
    // MARK: - Internal

    @Environment(\.parra) var parra

    var body: some View {
        List {
            Section {
                AccountHeader()
            }

            Section {
                NavigationLink {
                    EditProfileView()
                } label: {
                    HStack {
                        Text("Edit Profile")
                        Spacer()
                        Text(displayName)
                            .foregroundStyle(.gray)
                    }
                }
            }

            Section("Login Methods") {
                HStack {
                    Text("Email")
                    Spacer()
                    Text(email)
                        .foregroundStyle(.gray)
                }
            }

            Section("Security") {
                ChangePasswordCell()
            }

            Section {
                LogoutCell()
            }

            Section("Danger Zone") {
                DeleteAccountCell()
            }
        }
        .navigationTitle("Account")
        .onReceive(parra.user.$current) { user in
            displayName = user?.info.displayName ?? ""
            email = user?.info.email ?? ""
        }
    }

    // MARK: - Private

    @State private var displayName = ""
    @State private var email = ""
}

#Preview {
    ParraAppPreview(authState: .authenticatedPreview) {
        AccountView()
    }
}
