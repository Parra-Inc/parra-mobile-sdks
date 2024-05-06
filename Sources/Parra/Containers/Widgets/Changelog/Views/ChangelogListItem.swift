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
        let palette = themeObserver.theme.palette

        VStack(alignment: .leading, spacing: 12) {
            componentFactory.buildLabel(
                fontStyle: .headline,
                content: content.name
            )
            .frame(maxWidth: .infinity, alignment: .leading)
            .multilineTextAlignment(.leading)

            withContent(
                content: content.description
            ) { content in
                componentFactory.buildLabel(
                    fontStyle: .body,
                    content: content
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
        .applyCornerRadii(size: .lg, from: themeObserver.theme)
    }

    // MARK: - Private

    @Environment(ChangelogWidgetConfig.self) private var config

    @EnvironmentObject private var contentObserver: ChangelogWidget
        .ContentObserver
    @EnvironmentObject private var componentFactory: ComponentFactory
    @EnvironmentObject private var themeObserver: ParraThemeObserver
}
