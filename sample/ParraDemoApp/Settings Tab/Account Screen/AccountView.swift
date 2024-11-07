//
//  AccountView.swift
//  Parra Demo
//
//  Bootstrapped with ❤️ by Parra on 11/07/2024.
//  Copyright © 2024 Parra Inc.. All rights reserved.
//

import Parra
import SwiftUI

struct AccountView: View {
    @Environment(\.parraAuthState) private var parraAuthState
    @Environment(\.parraTheme) private var parraTheme
    
    @State private var isSigningIn = false
    @State private var isEditProfilePresented = false

    var body: some View {
        let user = parraAuthState.user

        List {
            Section {
                AccountHeader()
            }

            Section() {
                Button {
                    isEditProfilePresented = true
                } label: {
                    HStack {
                        Text("Edit Profile")
                            .foregroundStyle(Color(UIColor.label))

                        Spacer()

                        Text(user?.info.displayName ?? "")
                            .foregroundStyle(.gray)

                        Image(systemName: "chevron.forward")
                            .font(Font.system(.caption).weight(.bold))
                            .foregroundColor(Color(UIColor.tertiaryLabel))
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
                    .presentParraSignInWidget(isPresented: $isSigningIn)
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

                    if user.info.hasPassword {
                        Section("Security") {
                            ChangePasswordCell()
                        }
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
        .navigationTitle("Account")
        .sheet(isPresented: $isEditProfilePresented) {
            NavigationStack {
                EditProfileView()
            }
        }
    }
}

#Preview {
    ParraAppPreview(authState: .undetermined) {
        AccountView()
    }
}
