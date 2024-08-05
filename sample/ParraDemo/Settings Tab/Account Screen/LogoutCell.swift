//
//  LogoutCell.swift
//  Parra Demo
//
//  Bootstrapped with ❤️ by Parra on 08/05/2024.
//  Copyright © 2024 Parra Inc.. All rights reserved.
//

import Parra
import SwiftUI

struct LogoutCell: View {
    @Environment(\.parra) private var parra
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    @EnvironmentObject private var themeManager: ParraThemeManager

    @ViewBuilder
    var body: some View {
        Button(
            action: {
                Task {
                    await parra.auth.logout()

                    presentationMode.wrappedValue.dismiss()
                }
            }
        ) {
            Label(
                title: { Text("Logout") },
                icon: {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                }
            )
        }
        .foregroundStyle(themeManager.theme.palette.error)
    }
}

#Preview {
    ParraAppPreview {
        LogoutCell()
    }
}
