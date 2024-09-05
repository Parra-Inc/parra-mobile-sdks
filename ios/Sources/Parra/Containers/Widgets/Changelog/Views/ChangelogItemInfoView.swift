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

    let version: ParraLabelContent
    let type: ParraLabelContent
    let createdAt: ParraLabelContent

    var body: some View {
        let palette = parraTheme.palette

        HStack(alignment: .center, spacing: 4) {
            componentFactory.buildBadge(
                size: .md,
                text: version.text,
                swatch: palette.success,
                iconSymbol: "circle.fill"
            )

            componentFactory.buildBadge(
                size: .md,
                text: type.text
            )

            Spacer()

            componentFactory.buildLabel(
                content: createdAt,
                localAttributes: ParraAttributes.Label(
                    text: ParraAttributes.Text(
                        style: .caption,
                        color: palette.secondaryText.toParraColor()
                    )
                )
            )
        }
    }

    // MARK: - Private

    @Environment(ParraChangelogWidgetConfig.self) private var config
    @Environment(\.parraTheme) private var parraTheme
    @Environment(ComponentFactory.self) private var componentFactory
}
