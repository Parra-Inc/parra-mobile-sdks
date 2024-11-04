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
