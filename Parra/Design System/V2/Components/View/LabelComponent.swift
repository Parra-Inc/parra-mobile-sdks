//
//  LabelComponent.swift
//  Parra
//
//  Created by Mick MacCallum on 1/29/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

struct LabelComponent: LabelComponentType {
    var config: LabelConfig
    var content: LabelContent
    var style: ParraAttributedLabelStyle

    static func applyStandardCustomizations(
        onto inputAttributes: LabelAttributes?,
        theme: ParraTheme,
        config: LabelConfig
    ) -> LabelAttributes {
        let base = inputAttributes ?? LabelAttributes()

        let defaultAttributes = switch config.type {
        case .body:
            LabelAttributes(
                font: base.font ?? .system(.body),
                fontColor: base.fontColor ?? theme.palette.primaryText
            )
        case .description:
            LabelAttributes(
                font: base.font ?? .system(.subheadline),
                fontColor: base.fontColor ?? theme.palette.secondaryText
            )
        case .title:
            LabelAttributes(
                font: base.font ?? .system(.largeTitle),
                fontColor: base.fontColor ?? theme.palette.primaryText,
                fontWeight: base.fontWeight ?? .bold
            )
        }

        return base.withUpdates(
            updates: defaultAttributes
        )
    }

    var body: some View {
        Label(
            // indended to be customized by the style object.
            title: { EmptyView() },
            icon: { EmptyView() }
        )
        .labelStyle(style)
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
        config: config,
        content: content,
        style: ParraAttributedLabelStyle(
            config: config,
            content: content,
            attributes: mergedAttributes,
            theme: theme
        )
    )
}

#Preview {
    return VStack(alignment: .leading, spacing: 16) {
        renderLabel(
            config: .init(type: .body),
            content: .init(text: "Default config")
        )

        renderLabel(
            config: .init(type: .title),
            content: .init(text: "A large title")
        )

        renderLabel(
            config: .init(type: .description),
            content: .init(text: "A subheadline")
        )

        renderLabel(
            config: .init(type: .body),
            content: .init(text: "With a background"),
            attributes: .init(
                background: .red,
                font: .title,
                fontColor: Color.green
            )
        )

        renderLabel(
            config: .init(type: .title),
            content: .init(text: "With a gradient background"),
            attributes: .init(
                background: Gradient(colors: [.pink, .purple]),
                cornerRadius: .init(allCorners: 4),
                fontColor: Color.white,
                padding: .init(top: 4, leading: 10, bottom: 4, trailing: 10)
            )
        )

        renderLabel(
            config: .init(type: .description),
            content: .init(text: "With a corner radius"),
            attributes: .init(
                background: .green,
                cornerRadius: .init(allCorners: 12),
                padding: .init(top: 6, leading: 6, bottom: 6, trailing: 6)
            )
        )
   }
}
