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
    @Environment(\.parraAuthState) private var parraAuthState
    @Environment(\.parraTheme) private var parraTheme

    @State private var isSigningIn = false

    var body: some View {
        let user = parraAuthState.user

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
                        Text(user?.info.displayName ?? "")
                            .foregroundStyle(.gray)
                    }
                }
            }

            // Anonymous users can't sign out, change password, etc.
            if let user {
                if user.info.isAnonymous {
                    Section {
                        Button(
                            action: {
                                isSigningIn = true
                            }
                        ) {
                            Text("Link an email")
                        }
                    }
                    .presentParraSignInView(isPresented: $isSigningIn)
                } else {
                    Section("Login Methods") {
                        ForEach(user.info.identities) { identity in
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
            }
        }
        .background(parraTheme.palette.primaryBackground)
        .scrollContentBackground(.hidden)
        .navigationTitle("Account")
    }
}

#Preview {
    ParraAppPreview(authState: .undetermined) {
        AccountView()
    }
}
