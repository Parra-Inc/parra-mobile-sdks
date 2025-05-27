//
//  ThemeCell.swift
//  Parra Demo
//
//  Bootstrapped with ❤️ by Parra on 05/27/2025.
//  Copyright © 2025 Parra Inc.. All rights reserved.
//

import Parra
import SwiftUI

struct ThemeCell: View {
    @Environment(\.parraPreferredAppearance) private var appearance

    var body: some View {
        Picker(
            selection: appearance,
            content: {
                ForEach(ParraAppearance.allCases) { option in
                    Text(option.description).tag(option)
                }
            },
            label: {
                ListItemLabel(
                    text: "Theme",
                    symbol: "paintbrush"
                )
            }
        )
    }
}

#Preview {
    ParraAppPreview {
        ThemeCell()
    }
}
