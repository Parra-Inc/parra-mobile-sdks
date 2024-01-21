//
//  StatefulButtonStyle.swift
//  Parra
//
//  Created by Mick MacCallum on 1/31/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

// maybe: ParraButtonStyle protocol that requires style inputs for different states
// and we use a conforming ParraDefaultButtonStyle struct internally.

internal struct StatefulButtonStyle: SwiftUI.ButtonStyle {
    let config: ButtonConfig
    let content: ButtonContent
    let titleStyle: TextStyle
    let pressedTitleStyle: TextStyle
    let disabledTitleStyle: TextStyle

    @ViewBuilder
    func makeBody(configuration: Configuration) -> some View {
        let currentTitleStyle = if content.isDisabled {
            disabledTitleStyle
        } else if configuration.isPressed {
            pressedTitleStyle
        } else {
            titleStyle
        }

        TextComponent(
            config: config.title,
            content: content.title,
            style: currentTitleStyle
        )
    }
}
