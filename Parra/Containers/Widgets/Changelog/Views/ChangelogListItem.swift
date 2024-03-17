//
//  ChangelogListItem.swift
//  Parra
//
//  Created by Mick MacCallum on 3/16/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

struct ChangelogListItem: View {
    // MARK: - Internal

    let content: AppReleaseContent

    var body: some View {
        let palette = themeObserver.theme.palette

        VStack(alignment: .leading, spacing: 12) {
            componentFactory.buildLabel(
                config: config.releasePreviewNames,
                content: content.name,
                suppliedBuilder: builderConfig.releasePreviewNames
            )
            .frame(maxWidth: .infinity, alignment: .leading)
            .multilineTextAlignment(.leading)

            withContent(content: content.description) { content in
                componentFactory.buildLabel(
                    config: config.releasePreviewDescriptions,
                    content: content,
                    suppliedBuilder: builderConfig.releasePreviewDescriptions
                )
                .lineLimit(3)
                .truncationMode(.tail)
                .multilineTextAlignment(.leading)
            }

            HStack(alignment: .center, spacing: 4) {
                Badge(
                    size: .md,
                    text: content.version.text,
                    color: palette.success,
                    icon: .symbol("circle.fill")
                )

                Badge(
                    size: .md,
                    text: content.type.text
                )

                Spacer()

                componentFactory.buildLabel(
                    config: config.releasePreviewCreatedAts,
                    content: content.createdAt,
                    suppliedBuilder: builderConfig.releasePreviewCreatedAts,
                    localAttributes: LabelAttributes(
                        fontColor: palette.secondaryText
                    )
                )
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .applyBackground(palette.secondaryBackground)
        .applyCornerRadii(size: .lg, from: themeObserver.theme)
    }

    // MARK: - Private

    @Environment(ChangelogWidgetConfig.self) private var config
    @Environment(ChangelogWidgetBuilderConfig.self) private var builderConfig
    @EnvironmentObject private var contentObserver: ChangelogWidget
        .ContentObserver
    @EnvironmentObject private var componentFactory: ComponentFactory
    @EnvironmentObject private var themeObserver: ParraThemeObserver
}
