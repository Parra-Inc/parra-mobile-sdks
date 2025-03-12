//
//  FeedCreatorUpdateContentView.swift
//  Parra
//
//  Created by Mick MacCallum on 12/16/24.
//

import SwiftUI

struct FeedCreatorUpdateContentView: View {
    // MARK: - Internal

    let creatorUpdate: ParraCreatorUpdateAppStub
    let lineLimit: Int?

    var body: some View {
        VStack(spacing: 0) {
            withContent(content: creatorUpdate.title) { content in
                componentFactory.buildLabel(
                    text: content,
                    localAttributes: ParraAttributes.Label(
                        text: ParraAttributes.Text(
                            style: .headline
                        ),
                        padding: .custom(
                            EdgeInsets(top: 6, leading: 0, bottom: 0, trailing: 0)
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

            withContent(content: creatorUpdate.body) { content in
                Text(
                    content.attributedStringWithHighlightedLinks(
                        tint: theme.palette.primary.toParraColor(),
                        font: .system(.callout),
                        foregroundColor: theme.palette.secondaryText
                            .toParraColor()
                    )
                )
                .textSelection(.enabled)
                .font(.body)
                .padding(.top, 3)
                .padding(.bottom, 6)
                .tint(theme.palette.primary.toParraColor())
                .lineLimit(lineLimit)
                .frame(
                    maxWidth: .infinity,
                    alignment: .leading
                )
            }
        }
    }

    // MARK: - Private

    @Environment(\.parraComponentFactory) private var componentFactory
    @Environment(\.parraTheme) private var theme
}
