//
//  ReleaseChangelogSectionView.swift
//  Parra
//
//  Created by Mick MacCallum on 3/18/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

struct ReleaseChangelogSectionView: View {
    let content: AppReleaseSectionContent

    @Environment(ChangelogWidgetConfig.self) var config
    @Environment(ChangelogWidgetBuilderConfig.self) var builderConfig
    @EnvironmentObject var componentFactory: ComponentFactory

    var combinedText: String {
        content.items.map { item in
            item.title.text
        }.joined(separator: "\n")
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            componentFactory.buildLabel(
                config: config.releaseDetailSectionTitle,
                content: content.title,
                suppliedBuilder: builderConfig.releaseDetailSectionTitle
            )

            componentFactory.buildLabel(
                config: config.releaseDetailSectionItem,
                content: LabelContent(text: combinedText),
                suppliedBuilder: builderConfig.releaseDetailSectionItem
            )
            .multilineTextAlignment(.leading)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    ParraContainerPreview<ChangelogWidget> { _, _, _, _ in
        VStack(spacing: 24) {
            Spacer()
            ReleaseChangelogSectionView(
                content: AppReleaseSectionContent(
                    AppReleaseSection.validStates()[0]
                )
            )
            ReleaseChangelogSectionView(
                content: AppReleaseSectionContent(
                    AppReleaseSection.validStates()[1]
                )
            )
            ReleaseChangelogSectionView(
                content: AppReleaseSectionContent(
                    AppReleaseSection.validStates()[2]
                )
            )
            Spacer()
        }
        .safeAreaPadding()
    }
}
