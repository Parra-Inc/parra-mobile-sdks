//
//  ParraGlobalComponentAttributes+Segment.swift
//  Parra
//
//  Created by Mick MacCallum on 5/9/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

public extension ParraGlobalComponentAttributes {
    func segmentedControlAttributes(
        localAttributes: ParraAttributes.Segment?,
        theme: ParraTheme
    ) -> ParraAttributes.Segment {
        return ParraAttributes.Segment(
            selectedOptionLabels: ParraAttributes.Label(
                text: ParraAttributes.Text(
                    style: .body,
                    color: theme.palette.primaryText.toParraColor()
                ),
                background: theme.palette.primary.toParraColor()
            ),
            unselectedOptionLabels: ParraAttributes.Label(
                text: ParraAttributes.Text(
                    style: .body,
                    color: theme.palette.secondaryText.toParraColor()
                ),
                background: theme.palette.secondaryBackground
            ),
            border: ParraAttributes.Border(
                width: 1.5,
                color: theme.palette.primarySeparator.toParraColor()
            ),
            cornerRadius: .md
        ).mergingOverrides(localAttributes)
    }
}
