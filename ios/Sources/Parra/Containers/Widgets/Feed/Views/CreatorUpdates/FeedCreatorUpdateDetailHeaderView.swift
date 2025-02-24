//
//  FeedCreatorUpdateDetailHeaderView.swift
//  Parra
//
//  Created by Mick MacCallum on 12/16/24.
//

import SwiftUI
import UIKit

struct FeedCreatorUpdateDetailHeaderView: View {
    // MARK: - Internal

    let creatorUpdate: ParraCreatorUpdateAppStub
    let feedItem: ParraFeedItem
    let containerGeometry: GeometryProxy
    @StateObject var reactor: Reactor

    var body: some View {
        VStack(spacing: 0) {
            FeedCreatorUpdateHeaderView(
                creatorUpdate: creatorUpdate
            )
            .padding([.horizontal, .top], 16)

            FeedCreatorUpdateContentView(
                creatorUpdate: creatorUpdate,
                lineLimit: nil
            )
            .padding(.horizontal, 16)

            if let attachments = creatorUpdate.attachments?.elements,
               !attachments.isEmpty,
               containerGeometry.size.width > 0 && containerGeometry.size.height > 0
            {
                ParraPaywalledContentView(
                    entitlement: creatorUpdate.attachmentPaywall?.entitlement,
                    context: creatorUpdate.attachmentPaywall?.context
                ) { requiredEntitlement, unlock in
                    CreatorUpdateAttachmentsView(
                        attachments: attachments,
                        containerGeometry: containerGeometry,
                        requiredEntitlement: requiredEntitlement
                    ) {
                        do {
                            try await unlock()
                        } catch {
                            Logger.error("Error unlocking attachment", error)
                        }
                    }
                } unlockedContentBuilder: {
                    CreatorUpdateAttachmentsView(
                        attachments: attachments,
                        containerGeometry: containerGeometry
                    )
                }
                .padding(.top, 8)
            }

            if reactor.showReactions {
                FeedReactionView(
                    feedItem: feedItem,
                    reactor: _reactor,
                    showCommentCount: false,
                    attachmentPaywall: creatorUpdate.attachmentPaywall
                )
                .padding()
                .frame(
                    maxWidth: .infinity,
                    alignment: .leading
                )
            }
        }
        .background(theme.palette.primaryBackground)
    }

    // MARK: - Private

    @Environment(\.parraTheme) private var theme
}
