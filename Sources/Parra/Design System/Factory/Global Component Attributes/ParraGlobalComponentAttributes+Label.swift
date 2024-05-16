//
//  ParraGlobalComponentAttributes+Label.swift
//  Parra
//
//  Created by Mick MacCallum on 5/3/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Foundation
import SwiftUI

// MARK: - Font.TextStyle + CustomStringConvertible

extension Font.TextStyle: CustomStringConvertible {
    public var description: String {
        switch self {
        case .largeTitle:
            return "largeTitle"
        case .title:
            return "title"
        case .headline:
            return "headline"
        case .subheadline:
            return "subheadline"
        case .body:
            return "body"
        case .callout:
            return "callout"
        case .caption:
            return "caption"
        case .footnote:
            return "footnote"
        default:
            return "unknown"
        }
    }
}

public extension ParraGlobalComponentAttributes {
    func labelAttributes(
        localAttributes: ParraAttributes.Label? = nil,
        theme: ParraTheme
    ) -> ParraAttributes.Label {
        let fontType = localAttributes?.text.fontType ?? .style(style: .body)

        let text: ParraAttributes.Text = switch fontType {
        case .custom(let font):
            ParraAttributes.Text(
                font: font
            )
        case .size(
            let size,
            let width,
            let weight,
            let design
        ):
            ParraAttributes.Text(
                fontSize: size,
                width: width,
                weight: weight,
                design: design,
                color: theme.palette.primaryText.toParraColor()
            )
        case .style(
            let style,
            let width,
            let weight,
            let design
        ):
            textAttributes(
                for: style,
                theme: theme
            ).mergingOverrides(
                ParraAttributes.Text(
                    style: style,
                    width: width,
                    weight: weight,
                    design: design,
                    color: theme.palette.primaryText.toParraColor()
                )
            )
        }

        return ParraAttributes.Label(
            text: text,
            icon: ParraAttributes.Image(
                tint: text.color
            )
        ).mergingOverrides(localAttributes)
    }
}
