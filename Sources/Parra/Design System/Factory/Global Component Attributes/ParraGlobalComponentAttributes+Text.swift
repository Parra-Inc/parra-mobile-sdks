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
        for textStyle: ParraTextStyle,
        localAttributes: ParraAttributes.Text? = nil,
        theme: ParraTheme
    ) -> ParraAttributes.Text {
        if let overridenAttributes = theme.typography.getTextAttributes(
            for: textStyle
        ) {
            return overridenAttributes
        }

        let font = Font.system(textStyle.systemTextStyle)

        let attributes = switch textStyle {
        case .body:
            ParraAttributes.Text(
                font: font,
                color: theme.palette.primaryText.toParraColor()
            )
        case .subheadline:
            ParraAttributes.Text(
                font: font,
                color: theme.palette.primaryText.toParraColor()
            )
        case .largeTitle, .title, .title2, .title3:
            ParraAttributes.Text(
                font: font,
                weight: .bold,
                color: theme.palette.primaryText.toParraColor(),
                alignment: .leading
            )
        case .callout:
            ParraAttributes.Text(
                font: font,
                weight: .medium,
                color: theme.palette.secondaryText.toParraColor().opacity(0.8)
            )
        default:
            ParraAttributes.Text(
                font: font
            )
        }

        return attributes.mergingOverrides(localAttributes)
    }
}
