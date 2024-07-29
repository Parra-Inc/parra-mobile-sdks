//
//  ChangePasswordCell.swift
//  Parra Demo
//
//  Bootstrapped with ❤️ by Parra on 07/29/2024.
//  Copyright © 2024 Parra Inc.. All rights reserved.
//

import Parra
import SwiftUI

struct ChangePasswordCell: View {
    // MARK: - Internal

    var body: some View {
        Button(action: {
            isChangePasswordPresented = true
        }) {
            Label(
                title: {
                    Text("Change Password")
                        .foregroundStyle(Color.primary)
                },
                icon: {
                    Image(systemName: "key.fill")
                }
            )
        }
        .presentParraChangePasswordView(
            isPresented: $isChangePasswordPresented
        )
    }

    // MARK: - Private

    @Environment(\.parra) private var parra

    @State private var isChangePasswordPresented = false
}

#Preview {
    ParraAppPreview(authState: .authenticatedPreview) {
        ChangePasswordCell()
    }
}
