//
//  AccountView.swift
//  {{ app.name.raw }}
//
//  Bootstrapped with ❤️ by Parra on {{ "now" | date: "%m/%d/%Y" }}.
//  Copyright © {{ "now" | date: "%Y" }} {{ tenant.name }}. All rights reserved.
//

import Parra
import SwiftUI

struct AccountView: View {
    @Environment(\.parra) private var parra

    @State private var displayName = ""
    @State private var email = ""
    @State private var identities: [Identity] = []

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
                ForEach(identities) { identity in
                    HStack {
                        Text(identity.name)

                        Spacer()

                        Text(identity.value ?? "")
                            .foregroundStyle(.gray)
                    }
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

            identities = user?.info.identities ?? []
        }
    }
}

#Preview {
    ParraAppPreview(authState: .authenticatedPreview) {
        AccountView()
    }
}
