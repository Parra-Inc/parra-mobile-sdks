//
//  LogoutCell.swift
//  Sample
//
//  Created by Mick MacCallum on 7/8/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
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
        .foregroundStyle(themeObserver.theme.palette.error)
    }

    // MARK: - Private

    @Environment(\.parra) private var parra

    @EnvironmentObject private var themeObserver: ParraThemeObserver
}

#Preview {
    ParraAppPreview {
        LogoutCell()
    }
}
