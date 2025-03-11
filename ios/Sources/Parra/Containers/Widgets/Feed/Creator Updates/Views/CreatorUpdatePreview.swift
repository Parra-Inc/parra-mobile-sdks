//
//  CreatorUpdatePreview.swift
//  Parra
//
//  Created by Mick MacCallum on 3/11/25.
//

import SwiftUI

struct CreatorUpdatePreview: View {
    // MARK: - Internal

    var creatorUpdate: ParraCreatorUpdateAppStub
    var spacing: CGFloat
    var containerGeometry: GeometryProxy

    var body: some View {
        VStack(spacing: 0) {
            FeedCreatorUpdateHeaderView(
                creatorUpdate: creatorUpdate
            )
            .padding([.horizontal, .top], 16)

            FeedCreatorUpdateContentView(
                creatorUpdate: creatorUpdate,
                lineLimit: 8
            )
            .padding(.horizontal, 16)
            .padding(.bottom, 12)

            if let attachments = creatorUpdate.attachments?.elements,
               !attachments.isEmpty
            {
                CreatorUpdateAttachmentsView(
                    attachments: attachments,
                    containerGeometry: containerGeometry
                )
            }
        }

        .background(parraTheme.palette.secondaryBackground)
        .applyCornerRadii(size: .xl, from: parraTheme)
        .buttonStyle(.plain)
        .padding(.vertical, spacing)
        .safeAreaPadding(.horizontal)
    }

    // MARK: - Private

    @Environment(\.parraTheme) private var parraTheme

    private var hasAttachments: Bool {
        guard let attachments = creatorUpdate.attachments?.elements else {
            return false
        }

        return !attachments.isEmpty
    }
}
