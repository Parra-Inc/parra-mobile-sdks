//
//  ParraGlobalComponentAttributes+Text.swift
//  Parra
//
//  Created by Mick MacCallum on 5/3/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Foundation
import SwiftUI

public extension ParraGlobalComponentAttributes {
    func textAttributes(
        for textStyle: Font.TextStyle?,
        localAttributes: ParraAttributes.Text? = nil,
        theme: ParraTheme
    ) -> ParraAttributes.Text {
        if let overridenAttributes = theme.typography.getTextAttributes(
            for: textStyle
        ) {
            return overridenAttributes
        }

        let style = textStyle ?? .body

        let attributes = switch textStyle {
        case .body:
            ParraAttributes.Text(
                style: style,
                color: theme.palette.primaryText.toParraColor()
            )
        case .subheadline:
            ParraAttributes.Text(
                style: style,
                color: theme.palette.primaryText.toParraColor()
            )
        case .largeTitle, .title, .title2, .title3:
            ParraAttributes.Text(
                style: style,
                weight: .bold,
                color: theme.palette.primaryText.toParraColor(),
                alignment: .leading
            )
        case .callout:
            ParraAttributes.Text(
                style: style,
                weight: .medium,
                color: theme.palette.secondaryText.toParraColor().opacity(0.8)
            )
        default:
            ParraAttributes.Text(
                style: style
            )
        }

        return attributes.mergingOverrides(localAttributes)
    }
}
