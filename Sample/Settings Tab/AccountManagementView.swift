//
//  AccountManagementView.swift
//  Sample
//
//  Created by Mick MacCallum on 7/17/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

struct AccountManagementView: View {
    var body: some View {
        List {
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
        .navigationTitle("Manage account")
    }
}
