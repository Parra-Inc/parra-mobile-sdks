//
//  ParraTextButton.swift
//  Parra
//
//  Created by Mick MacCallum on 1/26/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

struct ParraTextButton: View {
    @EnvironmentObject var themeObserver: ParraThemeObserver

    let size: ParraButtonSize
    let variant: ParraButtonVariant
    let style: ParraButtonStyle
    let viewConfig: ParraButtonViewConfig

    @ViewBuilder
    func buildLabel(_ statefulConfig: ParraLabelViewConfig?) -> some View {
        themeObserver.theme.buildLabelView(
            text: "Small \(variant.description) Button",
            localConfig: statefulConfig
        )
    }

    var body: some View {
        let buttonConfig = themeObserver.theme.defaultButtonViewConfig(
            for: variant,
            style: style,
            size: size
        )

        switch variant {
        case .plain:
            ParraPlainButton(
                labelFactory: buildLabel,
                size: size,
                viewConfig: buttonConfig
            )
        case .outlined:
            ParraOutlinedButton(
                labelFactory: buildLabel,
                size: size,
                viewConfig: buttonConfig
            )
        case .contained:
            ParraContainedButton(
                labelFactory: buildLabel,
                size: size,
                viewConfig: buttonConfig
            )
        }
    }
}

#Preview {
    let theme = ParraTheme.default
    let themeObserver = ParraThemeObserver(
        theme: theme,
        notificationCenter: ParraNotificationCenter()
    )

    return VStack {
        ParraTextButton(
            size: .medium,
            variant: .plain,
            style: .primary,
            viewConfig: theme.defaultButtonViewConfig(
                for: .plain,
                style: .primary,
                size: .medium
            )
        )

        ParraTextButton(
            size: .medium,
            variant: .outlined,
            style: .primary,
            viewConfig: theme.defaultButtonViewConfig(
                for: .plain,
                style: .primary,
                size: .medium
            )
        )

        ParraTextButton(
            size: .medium,
            variant: .contained,
            style: .primary,
            viewConfig: theme.defaultButtonViewConfig(
                for: .plain,
                style: .primary,
                size: .medium
            )
        )
    }
    .environmentObject(themeObserver)
}
