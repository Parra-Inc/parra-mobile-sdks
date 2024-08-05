//
//  LogoutCell.swift
//  {{ app.name.raw }}
//
//  Bootstrapped with ❤️ by Parra on {{ "now" | date: "%m/%d/%Y" }}.
//  Copyright © {{ "now" | date: "%Y" }} {{ tenant.name }}. All rights reserved.
//

import Parra
import SwiftUI

struct LogoutCell: View {
    @Environment(\.parra) private var parra
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    @EnvironmentObject private var themeManager: ParraThemeManager

    var body: some View {
        Button(action: {
            Task {
                await parra.auth.logout()

                presentationMode.wrappedValue.dismiss()
            }
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
}

#Preview {
    ParraAppPreview {
        LogoutCell()
    }
}
