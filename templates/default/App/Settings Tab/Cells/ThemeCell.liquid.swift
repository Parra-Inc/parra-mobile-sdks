//
//  ThemeCell.swift
//  {{ app.name.raw }}
//
//  Bootstrapped with ❤️ by Parra on {{ "now" | date: "%m/%d/%Y" }}.
//  Copyright © {{ "now" | date: "%Y" }} {{ tenant.name }}. All rights reserved.
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
