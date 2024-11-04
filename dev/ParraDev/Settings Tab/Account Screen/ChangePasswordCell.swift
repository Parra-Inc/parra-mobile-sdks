//
//  ChangePasswordCell.swift
//  Parra Demo
//
//  Bootstrapped with ❤️ by Parra on 08/01/2024.
//  Copyright © 2024 Parra Inc.. All rights reserved.
//

import Parra
import SwiftUI

struct ChangePasswordCell: View {
    @State private var isChangePasswordPresented = false

    var body: some View {
        Button(action: {
            isChangePasswordPresented = true
        }) {
            ListItemLabel(
                text: "Change Password",
                symbol: "key.fill"
            )
        }
        .presentParraChangePasswordWidget(
            isPresented: $isChangePasswordPresented
        )
    }
}

#Preview {
    ParraAppPreview(authState: .authenticatedPreview) {
        ChangePasswordCell()
    }
}
