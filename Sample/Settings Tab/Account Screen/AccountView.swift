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
                        Text("Edit profile")
                        Spacer()
                        Text(displayName)
                    }
                }
            }

            Section("Login methods") {
                NavigationLink {} label: {
                    HStack {
                        Text("Email")
                        Spacer()
                        Text(email)
                    }
                }
            }

            Section("Security") {
                ChangePasswordCell()
            }

            Section("Danger zone") {
                LogoutCell()
                DeleteAccountCell()
            }
        }
        .navigationTitle("Account")
        .onReceive(parra.user.$current) { user in
            displayName = user?.info.displayName ?? "Unknown"
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
