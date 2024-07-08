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
        Text(
            "Choose if \(parraAppInfo.application.name)'s appearance should be light or dark, or follow your device's settings."
        )

        Picker("Theme", selection: $themeObserver.preferredAppearance) {
            ForEach(ParraAppearance.allCases) { option in
                Text(option.description).tag(option)
            }
        }
    }

    // MARK: - Private

    @EnvironmentObject private var themeObserver: ParraThemeObserver
    @EnvironmentObject private var parraAppInfo: ParraAppInfo
    @Environment(\.parra) private var parra
}

#Preview {
    ParraAppPreview {
        ThemeCell()
    }
}
