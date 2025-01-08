//
//  FeedCreatorUpdateHeaderView.swift
//  Parra
//
//  Created by Mick MacCallum on 12/16/24.
//

import SwiftUI

struct FeedCreatorUpdateHeaderView: View {
    // MARK: - Internal

    let creatorUpdate: ParraCreatorUpdateAppStub

    var body: some View {
        if let sender = creatorUpdate.sender {
            headerWithSender(sender)
        } else {
            createdAt
        }
    }

    // MARK: - Private

    @Environment(\.parraComponentFactory) private var componentFactory
    @Environment(\.parraTheme) private var parraTheme

    private var createdAt: some View {
        componentFactory.buildLabel(
            text: creatorUpdate.createdAt.timeAgo(),
            localAttributes: ParraAttributes.Label(
                text: .init(
                    style: .subheadline,
                    weight: .medium,
                    color: parraTheme.palette.secondaryText
                        .toParraColor()
                ),
                padding: .zero,
                frame: .flexible(
                    FlexibleFrameAttributes(maxWidth: .infinity, alignment: .leading)
                )
            )
        )
    }

    @ViewBuilder
    private func headerWithSender(
        _ sender: ParraCreatorUpdateSenderStub
    ) -> some View {
        HStack(spacing: 12) {
            if let avatar = sender.avatar {
                componentFactory.buildAsyncImage(
                    config: ParraAsyncImageConfig(
                        cachePolicy: .returnCacheDataElseLoad
                    ),
                    content: ParraAsyncImageContent(
                        avatar,
                        preferredThumbnailSize: .sm
                    )
                )
                .frame(
                    width: 46,
                    height: 46
                )
                .cornerRadius(25)
            }

            VStack(spacing: 0) {
                HStack(spacing: 4) {
                    componentFactory.buildLabel(
                        text: sender.name,
                        localAttributes: ParraAttributes.Label(
                            text: .init(
                                style: .headline,
                                weight: .bold
                            ),
                            padding: .zero
                        )
                    )

                    if sender.verified == true {
                        componentFactory.buildImage(
                            content: .name("CheckBadgeSolid", .module, .template),
                            localAttributes: ParraAttributes
                                .Image(
                                    tint: .blue,
                                    size: CGSize(width: 20, height: 20)
                                )
                        )
                    }

                    Spacer()
                }

                createdAt
            }
            .frame(
                maxWidth: .infinity,
                alignment: .leading
            )
        }
    }
}
