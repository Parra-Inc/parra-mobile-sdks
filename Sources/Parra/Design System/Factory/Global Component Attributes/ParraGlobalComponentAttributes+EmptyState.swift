//
//  ParraGlobalComponentAttributes+EmptyState.swift
//  Parra
//
//  Created by Mick MacCallum on 5/14/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

public extension ParraGlobalComponentAttributes {
    func emptyStateAttributes(
        localAttributes: ParraAttributes.EmptyState?,
        theme: ParraTheme
    ) -> ParraAttributes.EmptyState {
        let palette = theme.palette

        return ParraAttributes.EmptyState(
            titleLabel: ParraAttributes.Label(
                text: ParraAttributes.Text(
                    font: .title
                ),
                padding: .custom(
                    .padding(top: 12)
                )
            ),
            subtitleLabel: ParraAttributes.Label(
                text: ParraAttributes.Text(
                    font: .subheadline,
                    alignment: .center
                ),
                padding: .custom(
                    .padding(top: 12)
                )
            ),
            icon: ParraAttributes.Image(
                tint: palette.secondary.shade400.toParraColor(),
                size: CGSize(width: 96, height: 96),
                padding: .custom(
                    .padding(bottom: 24)
                )
            ),
            primaryActionButton: ParraAttributes.ContainedButton(
                normal: ParraAttributes.ContainedButton.StatefulAttributes(
                    label: ParraAttributes.Label(
                        frame: .flexible(.init(maxWidth: 240))
                    ),
                    padding: .custom(
                        .padding(top: 36, bottom: 4)
                    )
                )
            ),
            secondaryActionButton: ParraAttributes.PlainButton(
                normal: ParraAttributes.PlainButton.StatefulAttributes(
                    label: ParraAttributes.Label(
                        frame: .flexible(.init(maxWidth: 240))
                    )
                )
            ),
            tint: palette.primary.toParraColor(),
            padding: .xxl,
            background: palette.primaryBackground
        )
    }
}
