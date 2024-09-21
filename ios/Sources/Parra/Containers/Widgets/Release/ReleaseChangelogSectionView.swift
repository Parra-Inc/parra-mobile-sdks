//
//  ReleaseChangelogSectionView.swift
//  Parra
//
//  Created by Mick MacCallum on 3/18/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

struct ReleaseChangelogSectionView: View {
    // MARK: - Internal

    let content: AppReleaseSectionContent

    @Environment(ParraChangelogWidgetConfig.self) var config

    var combinedText: String {
        content.items.map { item in
            item.title.text
        }.joined(separator: "\n")
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            componentFactory.buildLabel(
                content: content.title,
                localAttributes: ParraAttributes.Label(
                    text: ParraAttributes.Text(
                        style: .title2
                    )
                )
            )

            componentFactory.buildLabel(
                content: ParraLabelContent(text: combinedText),
                localAttributes: ParraAttributes.Label(
                    text: ParraAttributes.Text(
                        style: .body,
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
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Private

    @Environment(\.parraComponentFactory) private var componentFactory
}

#Preview {
    ParraContainerPreview<ChangelogWidget> { _, _, _ in
        VStack(spacing: 24) {
            Spacer()
            ReleaseChangelogSectionView(
                content: AppReleaseSectionContent(
                    ParraAppReleaseSection.validStates()[0]
                )
            )
            ReleaseChangelogSectionView(
                content: AppReleaseSectionContent(
                    ParraAppReleaseSection.validStates()[1]
                )
            )
            ReleaseChangelogSectionView(
                content: AppReleaseSectionContent(
                    ParraAppReleaseSection.validStates()[2]
                )
            )
            Spacer()
        }
        .safeAreaPadding()
    }
}
