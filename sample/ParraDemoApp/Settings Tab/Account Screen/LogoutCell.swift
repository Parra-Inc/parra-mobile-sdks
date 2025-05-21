//
//  LogoutCell.swift
//  Parra Demo
//
//  Bootstrapped with ❤️ by Parra on 05/21/2025.
//  Copyright © 2025 Parra Inc.. All rights reserved.
//

import Parra
import SwiftUI

struct LogoutCell: View {
    @Environment(\.parra) private var parra
    @Environment(\.parraTheme) private var parraTheme
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    @ViewBuilder
    var body: some View {
        Button(
            action: {
                Task {
                    if await parra.auth.logout() {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        ) {
            ListItemLabel(
                text: "Logout",
                symbol: "rectangle.portrait.and.arrow.right"
            )
        }
        .foregroundStyle(parraTheme.palette.error)
    }
}

#Preview {
    ParraAppPreview {
        LogoutCell()
    }
}
