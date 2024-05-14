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
    @EnvironmentObject var componentFactory: ComponentFactory

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
                        font: .title2
                    )
                )
            )

            componentFactory.buildLabel(
                content: LabelContent(text: combinedText),
                localAttributes: ParraAttributes.Label(
                    text: ParraAttributes.Text(
                        font: .body,
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
}

#Preview {
    ParraContainerPreview<ChangelogWidget> { _, _, _ in
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
