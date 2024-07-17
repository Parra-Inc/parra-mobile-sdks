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
            Section("Account info") {
                ChangePasswordCell()
            }

            Section("Danger zone") {
                LogoutCell()
                DeleteAccountCell()
            }
        }
        .navigationTitle("Manage account")
    }
}
