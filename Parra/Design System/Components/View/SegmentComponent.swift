//
//  SegmentComponent.swift
//  Parra
//
//  Created by Mick MacCallum on 2/29/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

struct SegmentComponent: SegmentComponentType {
    var config: SegmentConfig
    let content: SegmentContent
    let style: ParraAttributedSegmentStyle

    var body: some View {
        SegmentView(
            options: content.options.map { .init(id: $0.id, title: $0.text) },
            style: style,
            onSelect: { option in
                content.optionSelected?(
                    .init(id: option.id, text: option.title)
                )
            },
            onConfirm: { option in
                content.optionConfirmed?(
                    .init(id: option.id, text: option.title)
                )
            }
        )
    }

    static func applyStandardCustomizations(
        onto inputAttributes: SegmentAttributes?,
        theme: ParraTheme,
        config: SegmentConfig
    ) -> SegmentAttributes {
        let palette = theme.palette

        let defaultAttributes = SegmentAttributes(
            optionLabels: LabelAttributes(
                font: Font.system(config.optionLabels.fontStyle),
                fontColor: palette.primaryText
            ),
            optionLabelBackgroundColor: palette.primaryBackground,
            optionLabelSelectedBackgroundColor: palette.primary.toParraColor(),
            optionLabelSelectedFontColor: palette.secondaryText.toParraColor(),
            cornerRadius: .md,
            borderWidth: 1.5,
            borderColor: palette.primarySeparator.toParraColor()
        )

        return defaultAttributes.withUpdates(
            updates: inputAttributes
        )
    }
}

private func renderSegment(
    config: SegmentConfig,
    content: SegmentContent,
    attributes: SegmentAttributes = .init(),
    theme: ParraTheme = .default
) -> some View {
    let mergedAttributes = SegmentComponent.applyStandardCustomizations(
        onto: attributes,
        theme: theme,
        config: config
    )

    return SegmentComponent(
        config: config,
        content: content,
        style: ParraAttributedSegmentStyle(
            config: config,
            content: content,
            attributes: mergedAttributes,
            theme: theme
        )
    )
}

#Preview {
    return VStack(alignment: .leading, spacing: 16) {
        renderSegment(
            config: SegmentConfig(optionLabels: LabelConfig(fontStyle: .body)),
            content: SegmentContent(
                options: ParraCardItemFixtures.ratingQuestionData.options.map {
                    SegmentContent.Option(
                        id: $0.id,
                        text: $0.title
                    )
                },
                optionSelected: nil,
                optionConfirmed: nil
            )
        )
    }
    .padding()
}
