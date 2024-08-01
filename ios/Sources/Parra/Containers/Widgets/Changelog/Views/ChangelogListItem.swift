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

    let content: AppReleaseStubContent

    var body: some View {
        let palette = themeManager.theme.palette

        VStack(alignment: .leading, spacing: 12) {
            componentFactory.buildLabel(
                content: content.name,
                localAttributes: ParraAttributes.Label(
                    text: ParraAttributes.Text(
                        style: .headline,
                        alignment: .leading
                    ),
                    frame: .flexible(
                        FlexibleFrameAttributes(
                            maxWidth: .infinity,
                            alignment: .leading
                        )
                    )
                )
            )

            withContent(
                content: content.description
            ) { content in
                componentFactory.buildLabel(
                    content: content,
                    localAttributes: ParraAttributes.Label(
                        text: ParraAttributes.Text(
                            style: .body,
                            alignment: .leading
                        )
                    )
                )
                .lineLimit(3)
                .truncationMode(.tail)
                .multilineTextAlignment(.leading)
            }

            ChangelogItemInfoView(
                content: content
            )
        }
        .frame(maxWidth: .infinity)
        .padding()
        .applyBackground(palette.secondaryBackground)
        .applyCornerRadii(size: .lg, from: themeManager.theme)
    }

    // MARK: - Private

    @Environment(ChangelogWidgetConfig.self) private var config

    @EnvironmentObject private var contentObserver: ChangelogWidget
        .ContentObserver
    @EnvironmentObject private var componentFactory: ComponentFactory
    @EnvironmentObject private var themeManager: ParraThemeManager
}
