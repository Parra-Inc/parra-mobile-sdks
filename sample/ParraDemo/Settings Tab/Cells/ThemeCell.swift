//
//  ThemeCell.swift
//  Parra Demo
//
//  Bootstrapped with ❤️ by Parra on 07/30/2024.
//  Copyright © 2024 Parra Inc.. All rights reserved.
//

import Parra
import SwiftUI

struct ThemeCell: View {
    // MARK: - Internal

    var body: some View {
        Picker(
            selection: $themeManager.preferredAppearance,
            content: {
                ForEach(ParraAppearance.allCases) { option in
                    Text(option.description).tag(option)
                }
            },
            label: {
                Label(
                    title: { Text("Theme") },
                    icon: { Image(systemName: "paintbrush") }
                )
            }
        )
    }

    // MARK: - Private

    @EnvironmentObject private var themeManager: ParraThemeManager
    @Environment(\.parra) private var parra
}

#Preview {
    ParraAppPreview {
        ThemeCell()
    }
}
