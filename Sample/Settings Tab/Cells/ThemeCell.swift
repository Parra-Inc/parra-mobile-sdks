//
//  ThemeCell.swift
//  Sample
//
//  Created by Mick MacCallum on 7/8/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Parra
import SwiftUI

struct ThemeCell: View {
    // MARK: - Internal

    var body: some View {
        Picker(
            selection: $themeObserver.preferredAppearance,
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

    @EnvironmentObject private var themeObserver: ParraThemeObserver
    @Environment(\.parra) private var parra
}

#Preview {
    ParraAppPreview {
        ThemeCell()
    }
}
