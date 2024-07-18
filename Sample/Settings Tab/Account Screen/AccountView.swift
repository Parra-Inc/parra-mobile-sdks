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

            IdentityLabels(user: parra.user!)
        }
        .padding()
        .frame(maxWidth: .infinity)
    }

    // MARK: - Private

    @Environment(\.parra) private var parra
}

struct AccountView: View {
    var body: some View {
        List {
            Section {
                AccountHeader()
            }

            Section {
                NavigationLink {
                    ProfileView()
                } label: {
                    Label(
                        title: { Text("Edit profile") },
                        icon: { Image(systemName: "person") }
                    )
                }
            }

            Section("Account info") {
                ChangePasswordCell()
            }

            Section {
                LogoutCell()
                DeleteAccountCell()
            }
        }
        .navigationTitle("My account")
    }
}

#Preview {
    ParraAppPreview {
        AccountView()
    }
}
