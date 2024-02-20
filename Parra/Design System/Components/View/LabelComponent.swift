//
//  LabelComponent.swift
//  Parra
//
//  Created by Mick MacCallum on 1/29/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

struct LabelComponent: LabelComponentType {
    let content: LabelContent
    let style: ParraAttributedLabelStyle

    var body: some View {
        Label(
            // indended to be customized by the style object.
            title: { EmptyView() },
            icon: { EmptyView() }
        )
        .labelStyle(style)
    }

    static func applyStandardCustomizations(
        onto inputAttributes: LabelAttributes?,
        theme: ParraTheme,
        config: LabelConfig
    ) -> LabelAttributes {
        let base = inputAttributes ?? LabelAttributes()
        let defaultFontStyle = Font.system(config.fontStyle)

        let defaultAttributes = base.withUpdates(
            updates: LabelAttributes(
                font: base.font ?? defaultFontStyle
            )
        )

        let styledAttributes: LabelAttributes? = switch config.fontStyle {
        case .body:
            LabelAttributes(
                fontColor: base.fontColor ?? theme.palette.primaryText
            )
        case .subheadline:
            LabelAttributes(
                fontColor: base.fontColor ?? theme.palette.secondaryText
            )
        case .title:
            LabelAttributes(
                fontColor: base.fontColor ?? theme.palette.primaryText,
                fontWeight: base.fontWeight ?? .bold
            )
        case .callout:
            LabelAttributes(
                fontColor: base.fontColor
                    ?? theme.palette.secondaryText.toParraColor().opacity(0.8),
                fontWeight: base.fontWeight ?? .medium
            )
        case .caption, .footnote, .caption2, .largeTitle, .headline,
             .title2, .title3:
            nil
        @unknown default:
            nil
        }

        return defaultAttributes.withUpdates(
            updates: styledAttributes
        )
    }
}

private func renderLabel(
    config: LabelConfig,
    content: LabelContent,
    attributes: LabelAttributes = .init(),
    theme: ParraTheme = .default
) -> some View {
    let mergedAttributes = LabelComponent.applyStandardCustomizations(
        onto: attributes,
        theme: theme,
        config: config
    )

    return LabelComponent(
        content: content,
        style: ParraAttributedLabelStyle(
            content: content,
            attributes: mergedAttributes,
            theme: theme
        )
    )
}

#Preview {
    return VStack(alignment: .leading, spacing: 16) {
        renderLabel(
            config: LabelConfig(fontStyle: .body),
            content: LabelContent(text: "Default config")
        )

        renderLabel(
            config: LabelConfig(fontStyle: .title),
            content: LabelContent(text: "A large title")
        )

        renderLabel(
            config: LabelConfig(fontStyle: .subheadline),
            content: LabelContent(text: "A subheadline")
        )

        renderLabel(
            config: LabelConfig(fontStyle: .body),
            content: LabelContent(text: "With a background"),
            attributes: LabelAttributes(
                background: .red,
                font: .title,
                fontColor: Color.green
            )
        )

        renderLabel(
            config: LabelConfig(fontStyle: .title),
            content: LabelContent(text: "With a gradient background"),
            attributes: LabelAttributes(
                background: Gradient(colors: [.pink, .purple]),
                cornerRadius: .extraSmall,
                fontColor: Color.white,
                padding: EdgeInsets(
                    top: 4,
                    leading: 10,
                    bottom: 4,
                    trailing: 10
                )
            )
        )

        renderLabel(
            config: LabelConfig(fontStyle: .subheadline),
            content: LabelContent(text: "With a corner radius"),
            attributes: LabelAttributes(
                background: .green,
                cornerRadius: .large,
                padding: EdgeInsets(top: 6, leading: 6, bottom: 6, trailing: 6)
            )
        )
    }
}
