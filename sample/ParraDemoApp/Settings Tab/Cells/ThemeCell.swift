//
//  ThemeCell.swift
//  Parra Demo
//
//  Bootstrapped with ❤️ by Parra on 10/24/2024.
//  Copyright © 2024 Parra Inc.. All rights reserved.
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
                Label(
                    title: { Text("Theme") },
                    icon: { Image(systemName: "paintbrush") }
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
