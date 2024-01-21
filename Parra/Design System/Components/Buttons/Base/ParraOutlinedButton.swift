//
//  ParraOutlinedButton.swift
//  Parra
//
//  Created by Mick MacCallum on 1/21/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

struct ParraOutlinedButton<Label>: View, ParraConfigurableView where Label: View {
    @ViewBuilder let labelFactory: (_ statefulConfig: ParraLabelViewConfig?) -> Label

    let size: ParraButtonSize
    let viewConfig: ParraButtonViewConfig

    @State private var isPressed = false

    private var state: ParraButtonState {
        if isPressed {
            return .pressed
        }

        //        if isDisabled {
        //            return .disabled
        //        }

        return .normal
    }

    var body: some View {
        let labelConfig = viewConfig.titleConfig(for: state)

        Button(action: buttonPressed, label: {
            labelFactory(labelConfig)
        })
        .applyViewConfig(viewConfig, variant: .outlined, size: size)
    }

    private func buttonPressed() {

    }
}

#Preview {
    let theme = ParraTheme.default

    return VStack(alignment: .leading) {
        ParraOutlinedButton(
            labelFactory: { statefulConfig in
                theme.buildLabelView(
                    text: "Outlined Button",
                    localConfig: statefulConfig
                )
            },
            size: .medium,
            viewConfig: theme.defaultButtonViewConfig(
                for: .outlined,
                style: .primary,
                size: .small
            )
        )

        ParraOutlinedButton(
            labelFactory: { statefulConfig in
                theme.buildLabelView(
                    text: "Outlined Button",
                    localConfig: statefulConfig
                )
            },
            size: .medium,
            viewConfig: theme.defaultButtonViewConfig(
                for: .outlined,
                style: .primary,
                size: .medium
            )
        )

        ParraOutlinedButton(
            labelFactory: { statefulConfig in
                theme.buildLabelView(
                    text: "Outlined Button",
                    localConfig: statefulConfig
                )
            },
            size: .medium,
            viewConfig: theme.defaultButtonViewConfig(
                for: .outlined,
                style: .primary,
                size: .large
            )
        )
    }
}
