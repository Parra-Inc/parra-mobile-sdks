//
//  AccountView.swift
//  Sample
//
//  Created by Mick MacCallum on 7/17/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Parra
import SwiftUI

struct AccountHeader: View {
    // MARK: - Internal

    var body: some View {
        VStack {
            ParraProfilePhotoWell(
                size: CGSize(width: 100, height: 100)
            )
            .padding(.bottom, 6)

            IdentityLabels(user: parra.currentUser!)
        }
        .padding()
        .frame(maxWidth: .infinity)
    }

    // MARK: - Private

    @Environment(\.parra) private var parra
}

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

                        Text(parra.currentUser?.info.displayName ?? "Unknown")
                    }
                }

                NavigationLink {} label: {
                    HStack {
                        Text("Email")
                            .disabled(true)

                        Spacer()

                        Text(parra.currentUser?.info.email ?? "")
                            .disabled(true)
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
    }

    // MARK: - Private

    @Environment(\.parra) private var parra
}

#Preview {
    ParraAppPreview(authState: .authenticatedPreview) {
        AccountView()
    }
}
