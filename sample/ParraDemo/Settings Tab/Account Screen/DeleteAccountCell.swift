//
//  DeleteAccountCell.swift
//  Parra Demo
//
//  Bootstrapped with ❤️ by Parra on 07/31/2024.
//  Copyright © 2024 Parra Inc.. All rights reserved.
//

import Parra
import SwiftUI

struct DeleteAccountCell: View {
    // MARK: - Internal

    var body: some View {
        Button(action: {
            parra.auth.deleteAccount()
        }) {
            Label(
                title: { Text("Delete Account") },
                icon: {
                    Image(systemName: "trash")
                }
            )
        }
        .foregroundStyle(themeManager.theme.palette.error)
    }

    // MARK: - Private

    @Environment(\.parra) private var parra
    @EnvironmentObject private var themeManager: ParraThemeManager
}

#Preview {
    ParraAppPreview {
        DeleteAccountCell()
    }
}
