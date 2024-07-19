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

    var body: some View {
        List {
            Section {
                AccountHeader()
            }

            Section("Personal info") {
                NavigationLink {
                    EditProfileView()
                } label: {
                    HStack {
                        Text("Name")
                        Spacer()
                        Text(displayName)
                    }
                }

                NavigationLink {} label: {
                    HStack {
                        Text("Email")
                        Spacer()
                        Text(email)
                    }
                }
            }

            Section("Sign in & security") {
                ChangePasswordCell()
            }

            Section("Manage account") {
                LogoutCell()
                DeleteAccountCell()
            }
        }
        .navigationTitle("My account")
        .onReceive(user.$current) { user in
            displayName = user?.info.displayName ?? "Unknown"
            email = user?.info.email ?? ""
        }
    }

    // MARK: - Private

    @Environment(\.parraUser) private var user

    @State private var displayName = ""
    @State private var email = ""
}

#Preview {
    ParraAppPreview(authState: .authenticatedPreview) {
        AccountView()
    }
}
