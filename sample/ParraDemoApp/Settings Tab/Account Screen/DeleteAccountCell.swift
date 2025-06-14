//
//  DeleteAccountCell.swift
//  Parra Demo
//
//  Bootstrapped with ❤️ by Parra on 06/11/2025.
//  Copyright © 2025 Parra Inc.. All rights reserved.
//

import Parra
import SwiftUI

struct DeleteAccountCell: View {
    @Environment(\.parra) private var parra
    @Environment(\.parraTheme) private var parraTheme
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    var body: some View {
        Button(action: {
            Task {
                do {
                    if try await parra.auth.deleteAccount() {
                        presentationMode.wrappedValue.dismiss()
                    }
                } catch {
                    ParraLogger.error("Error deleting account", error)
                }
            }
        }) {
            ListItemLabel(
                text: "Delete Account",
                symbol: "trash"
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
