//
//  LogoutCell.swift
//  Parra Demo
//
//  Bootstrapped with ❤️ by Parra on 08/01/2024.
//  Copyright © 2024 Parra Inc.. All rights reserved.
//

import Parra
import SwiftUI

struct LogoutCell: View {
    // MARK: - Internal

    var body: some View {
        Button(action: {
            parra.auth.logout()
        }) {
            Label(
                title: { Text("Logout") },
                icon: {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
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
        LogoutCell()
    }
}
