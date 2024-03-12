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
        .contentShape(Rectangle())
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
        case .largeTitle, .title, .title2, .title3:
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
        case .caption, .footnote, .caption2, .headline:
            nil
        @unknown default:
            nil
        }

        return defaultAttributes
            .withUpdates(
                updates: styledAttributes
            )
    }
}

#Preview {
    ParraViewPreview { factory in
        VStack(alignment: .leading, spacing: 16) {
            factory.buildLabel(
                config: LabelConfig(fontStyle: .body),
                content: LabelContent(text: "Default config")
            )

            factory.buildLabel(
                config: LabelConfig(fontStyle: .title),
                content: LabelContent(text: "A large title")
            )

            factory.buildLabel(
                config: LabelConfig(fontStyle: .subheadline),
                content: LabelContent(text: "A subheadline")
            )

            factory.buildLabel(
                config: LabelConfig(fontStyle: .subheadline),
                content: LabelContent(
                    text: "A subheadline with icon",
                    icon: .symbol("sun.rain.circle.fill")
                )
            )

            factory.buildLabel(
                config: LabelConfig(fontStyle: .subheadline),
                content: LabelContent(
                    text: "A reversed subheadline with icon",
                    icon: .symbol("sun.rain.circle.fill")
                ),
                localAttributes: LabelAttributes(
                    layoutDirectionBehavior: .mirrors
                )
            )

            factory.buildLabel(
                config: LabelConfig(fontStyle: .body),
                content: LabelContent(text: "With a background"),
                localAttributes: LabelAttributes(
                    background: .red,
                    font: .title,
                    fontColor: Color.green
                )
            )

            factory.buildLabel(
                config: LabelConfig(fontStyle: .title),
                content: LabelContent(text: "With a gradient background"),
                localAttributes: LabelAttributes(
                    background: Gradient(colors: [.pink, .purple]),
                    cornerRadius: .xs,
                    fontColor: Color.white,
                    padding: EdgeInsets(
                        top: 4,
                        leading: 10,
                        bottom: 4,
                        trailing: 10
                    )
                )
            )

            factory.buildLabel(
                config: LabelConfig(fontStyle: .title),
                content: LabelContent(
                    text: "BG gradient and icon",
                    icon: .symbol("fireworks")
                ),
                localAttributes: LabelAttributes(
                    background: Gradient(colors: [.pink, .purple]),
                    cornerRadius: .xs,
                    fontColor: Color.white,
                    padding: EdgeInsets(
                        top: 4,
                        leading: 10,
                        bottom: 4,
                        trailing: 10
                    )
                )
            )

            factory.buildLabel(
                config: LabelConfig(fontStyle: .subheadline),
                content: LabelContent(text: "With a corner radius"),
                localAttributes: LabelAttributes(
                    background: .green,
                    cornerRadius: .lg,
                    padding: EdgeInsets(
                        top: 8,
                        leading: 8,
                        bottom: 8,
                        trailing: 8
                    )
                )
            )
        }
    }
}
