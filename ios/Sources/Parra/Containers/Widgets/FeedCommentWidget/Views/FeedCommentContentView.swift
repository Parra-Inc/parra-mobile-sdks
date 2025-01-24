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
            withContent(
                content: comment.user.avatar
            ) { avatar in
                componentFactory.buildAsyncImage(
                    config: ParraAsyncImageConfig(
                        contentMode: .fill
                    ),
                    content: ParraAsyncImageContent(
                        avatar,
                        preferredThumbnailSize: .md
                    ),
                    localAttributes: ParraAttributes.AsyncImage(
                        size: CGSize(width: 34, height: 34),
                        cornerRadius: .full
                    )
                )
            } elseRenderer: {
                componentFactory.buildImage(
                    config: ParraImageConfig(),
                    content: .symbol("person.crop.circle.fill", .hierarchical),
                    localAttributes: ParraAttributes.Image(
                        size: CGSize(width: 34, height: 34),
                        cornerRadius: .full
                    )
                )
                .foregroundStyle(
                    theme.palette.primary.toParraColor(),
                    theme.palette.primaryBackground
                )
            }

            VStack(alignment: .leading) {
                HStack(alignment: .center, spacing: 8) {
                    componentFactory.buildLabel(
                        text: comment.user.displayName,
                        localAttributes: ParraAttributes.Label(
                            text: .default(with: .headline),
                            padding: .zero
                        )
                    )

                    componentFactory.buildLabel(
                        text: comment.createdAt.timeAgoAbbreviated(),
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

                if comment.submissionErrorMessage != nil {
                    Button {
                        isShowingErrorAlert = true
                    } label: {
                        componentFactory.buildLabel(
                            content: ParraLabelContent(
                                text: "Not Delivered",
                                icon: .symbol("exclamationmark.circle")
                            ),
                            localAttributes: ParraAttributes.Label(
                                text: ParraAttributes.Text(
                                    style: .caption,
                                    color: theme.palette.error
                                        .toParraColor()
                                        .opacity(0.9)
                                ),
                                icon: ParraAttributes.Image(
                                    tint: theme.palette.error
                                        .toParraColor()
                                        .opacity(0.9),
                                    size: CGSize(width: 14, height: 14)
                                ),
                                padding: .zero
                            )
                        )
                    }
                } else {
                    reactionView()
                }
            }
            .frame(
                maxWidth: .infinity
            )
        }
        .alert(
            "Message Not Delivered",
            isPresented: $isShowingErrorAlert
        ) {
            Button(role: .cancel) {} label: {
                Text("Dismiss")
            }
        } message: {
            if let error = comment.submissionErrorMessage {
                Text(error)
            }
        }
    }

    // MARK: - Private

    @Environment(\.parraComponentFactory) private var componentFactory
    @Environment(\.parraTheme) private var theme

    @State private var isShowingErrorAlert = false
}
