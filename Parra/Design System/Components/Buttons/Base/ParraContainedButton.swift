//
//  ParraContainedButton.swift
//  Parra
//
//  Created by Mick MacCallum on 1/21/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

struct ParraContainedButton<Label>: View, ParraConfigurableView where Label: View {
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
                .if(size == .large) { view in
                    view.frame(maxWidth: .infinity)
                }
        })
        .applyViewConfig(viewConfig, variant: .contained, size: size)
    }

    private func buttonPressed() {

    }
}

#Preview {
    let theme = ParraTheme.default

    return VStack(alignment: .leading) {
        ParraContainedButton(
            labelFactory: { statefulConfig in
                theme.buildLabelView(
                    text: "Small Button",
                    localConfig: statefulConfig
                )
            },
            size: .small,
            viewConfig: theme.defaultButtonViewConfig(
                for: .contained,
                style: .primary,
                size: .small
            )
        )

        ParraContainedButton(
            labelFactory: { statefulConfig in
                theme.buildLabelView(
                    text: "Medium Button",
                    localConfig: statefulConfig
                )
            },
            size: .medium,
            viewConfig: theme.defaultButtonViewConfig(
                for: .contained,
                style: .primary,
                size: .medium
            )
        )

        ParraContainedButton(
            labelFactory: { statefulConfig in
                theme.buildLabelView(
                    text: "Large Button",
                    localConfig: statefulConfig
                )
            },
            size: .large,
            viewConfig: theme.defaultButtonViewConfig(
                for: .contained,
                style: .primary,
                size: .large
            )
        )
    }
    .padding()
}
