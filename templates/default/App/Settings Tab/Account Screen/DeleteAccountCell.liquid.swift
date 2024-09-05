//
//  DeleteAccountCell.swift
//  {{ app.name.raw }}
//
//  Bootstrapped with ❤️ by Parra on {{ "now" | date: "%m/%d/%Y" }}.
//  Copyright © {{ "now" | date: "%Y" }} {{ tenant.name }}. All rights reserved.
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
