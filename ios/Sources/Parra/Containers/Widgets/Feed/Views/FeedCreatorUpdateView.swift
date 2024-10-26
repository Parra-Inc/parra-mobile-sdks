//
//  FeedCreatorUpdateView.swift
//  Parra
//
//  Created by Mick MacCallum on 10/25/24.
//

import SwiftUI

// Need
// 1. View image previews in cell (count affects layout)
// 2. photo gallery
// 3.
// if wider than tall
//    others small underneath
// if square
//    others small underneath
// if taller than wide
//    others on right (see gator helmet photo)
//
// locked field will go

struct FeedCreatorUpdateView: View {
    // MARK: - Internal

    let creatorUpdate: ParraCreatorUpdateAppStub
    let containerGeometry: GeometryProxy
    let spacing: CGFloat
    let performActionForFeedItemData: (_ feedItemData: ParraFeedItemData) -> Void

    var body: some View {
        VStack {
            withContent(content: creatorUpdate.title) { content in
                Text(content)
                    .bold().font(.headline)
                    .padding()
                    .frame(
                        maxWidth: .infinity,
                        alignment: .leading
                    )
            }

            withContent(content: creatorUpdate.body) { content in
                Text(content)
                    .font(.body)
                    .frame(
                        maxWidth: .infinity,
                        alignment: .leading
                    )
            }

            ForEach(creatorUpdate.attachments?.elements ?? []) { attachment in
                if let image = attachment.image {
                    componentFactory.buildAsyncImage(
                        content: ParraAsyncImageContent(
                            url: image.url,
                            originalSize: image.size
                        )
                    )
                }
            }
        }
        .padding(.vertical, spacing)
    }

    // MARK: - Private

    @Environment(\.parraComponentFactory) private var componentFactory
}
