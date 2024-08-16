//
//  DeleteAccountCell.swift
//  Parra Demo
//
//  Bootstrapped with ❤️ by Parra on 08/16/2024.
//  Copyright © 2024 Parra Inc.. All rights reserved.
//

import Parra
import SwiftUI

struct DeleteAccountCell: View {
    @Environment(\.parra) private var parra
    @Environment(\.parraTheme) private var parraTheme

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
        .foregroundStyle(parraTheme.palette.error)
    }
}

#Preview {
    ParraAppPreview {
        DeleteAccountCell()
    }
}
