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
    @State private var isEditProfilePresented = false

    var body: some View {
        let user = parraAuthState.user

        Form {
            Section {
                AccountHeader()
            }
            .listRowBackground(parraTheme.palette.secondaryBackground)

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
            .listRowBackground(parraTheme.palette.secondaryBackground)

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
                    .listRowBackground(parraTheme.palette.secondaryBackground)
                    .presentParraSignInWidget(isPresented: $isSigningIn)
                } else {
                    let identities = user.info.identities.filter { identity in
                        identity.type != .anonymous
                    }

                    if !identities.isEmpty {
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
                        .listRowBackground(parraTheme.palette.secondaryBackground)
                    }

                    if user.info.hasPassword {
                        Section("Security") {
                            ChangePasswordCell()
                        }
                        .listRowBackground(parraTheme.palette.secondaryBackground)
                    }

                    Section {
                        LogoutCell()
                    }
                    .listRowBackground(parraTheme.palette.secondaryBackground)

                    Section("Danger Zone") {
                        DeleteAccountCell()
                    }
                    .listRowBackground(parraTheme.palette.secondaryBackground)
                }
            }
        }
        .background(parraTheme.palette.primaryBackground)
        .scrollContentBackground(.hidden)
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
