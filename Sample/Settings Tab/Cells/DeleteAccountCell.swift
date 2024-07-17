//
//  DeleteAccountCell.swift
//  Sample
//
//  Created by Mick MacCallum on 7/8/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
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
                title: { Text("Delete account") },
                icon: {
                    Image(systemName: "trash")
                }
            )
        }
        .foregroundStyle(themeObserver.theme.palette.error)
    }

    // MARK: - Private

    @Environment(\.parra) private var parra
    @EnvironmentObject private var themeObserver: ParraThemeObserver
}

#Preview {
    ParraAppPreview {
        DeleteAccountCell()
    }
}
