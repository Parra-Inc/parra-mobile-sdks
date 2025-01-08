//
//  FeedCommentContentView.swift
//  Parra
//
//  Created by Mick MacCallum on 12/19/24.
//

import SwiftUI

private let mainPadding = CGSize(width: 12.0, height: 8.0)

struct FeedCommentContentView<ReactionView>: View where ReactionView: View {
    // MARK: - Internal

    let comment: ParraComment
    @ViewBuilder let reactionView: () -> ReactionView

    var body: some View {
        HStack(alignment: .top, spacing: mainPadding.width) {
            withContent(content: comment.user.avatar) { avatar in
                componentFactory.buildAsyncImage(
                    content: ParraAsyncImageContent(
                        avatar,
                        preferredThumbnailSize: .sm
                    ),
                    localAttributes: ParraAttributes.AsyncImage(
                        size: CGSize(width: 34, height: 34),
                        cornerRadius: .full
                    )
                )
            }

            VStack(alignment: .leading) {
                HStack(alignment: .center, spacing: round(mainPadding.width / 3)) {
                    withContent(content: comment.user.name) { name in
                        componentFactory.buildLabel(
                            text: name,
                            localAttributes: ParraAttributes.Label(
                                text: .default(with: .headline),
                                padding: .zero
                            )
                        )
                    }

                    componentFactory.buildLabel(
                        text: comment.createdAt.timeAgo(
                            context: .standalone,
                            dateTimeStyle: .numeric,
                            unitStyle: .short
                        ),
                        localAttributes: ParraAttributes.Label(
                            text: .default(with: .caption),
                            padding: .zero
                        )
                    )
                }

                componentFactory.buildLabel(
                    text: comment.body,
                    localAttributes: ParraAttributes.Label(
                        frame: .flexible(
                            FlexibleFrameAttributes(
                                maxWidth: .infinity,
                                alignment: .leading
                            )
                        )
                    )
                )

                reactionView()
            }
            .frame(
                maxWidth: .infinity
            )
        }
    }

    // MARK: - Private

    @Environment(\.parraComponentFactory) private var componentFactory
}
