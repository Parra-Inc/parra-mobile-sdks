//
//  ChangelogItemInfoView.swift
//  Parra
//
//  Created by Mick MacCallum on 3/18/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

struct ChangelogItemInfoView: View {
    // MARK: - Lifecycle

    init(content: AppReleaseStubContent) {
        self.version = content.version
        self.type = content.type
        self.createdAt = content.createdAt
    }

    init(content: AppReleaseContent) {
        self.version = content.version
        self.type = content.type
        self.createdAt = content.createdAt
    }

    // MARK: - Internal

    let version: LabelContent
    let type: LabelContent
    let createdAt: LabelContent

    var body: some View {
        let palette = themeObserver.theme.palette

        HStack(alignment: .center, spacing: 4) {
            Badge(
                size: .md,
                text: version.text,
                color: palette.success,
                icon: .symbol("circle.fill")
            )

            Badge(
                size: .md,
                text: type.text
            )

            Spacer()

            componentFactory.buildLabel(
                config: config.releasePreviewCreatedAts,
                content: createdAt,
                suppliedBuilder: builderConfig.releasePreviewCreatedAts,
                localAttributes: LabelAttributes(
                    fontColor: palette.secondaryText
                )
            )
        }
    }

    // MARK: - Private

    @Environment(ChangelogWidgetConfig.self) private var config
    @Environment(ChangelogWidgetBuilderConfig.self) private var builderConfig
    @EnvironmentObject private var themeObserver: ParraThemeObserver
    @EnvironmentObject private var componentFactory: ComponentFactory
}
