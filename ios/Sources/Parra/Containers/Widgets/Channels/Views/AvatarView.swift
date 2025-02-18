//
//  AvatarView.swift
//  Parra
//
//  Created by Mick MacCallum on 2/13/25.
//

import SwiftUI
import UIKit

struct AvatarView: View {
    // MARK: - Lifecycle

    init(
        avatar: ParraImageAsset?,
        size: CGSize = CGSize(width: 34, height: 34),
        showLoadingIndicator: Bool = true
    ) {
        self.avatar = avatar
        self.size = size
        self.showLoadingIndicator = showLoadingIndicator
    }

    // MARK: - Internal

    var avatar: ParraImageAsset?
    var size: CGSize
    var showLoadingIndicator: Bool

    var body: some View {
        withContent(
            content: avatar
        ) { avatar in
            componentFactory.buildAsyncImage(
                config: ParraAsyncImageConfig(
                    contentMode: .fill,
                    showLoadingIndicator: showLoadingIndicator
                ),
                content: ParraAsyncImageContent(
                    avatar,
                    preferredThumbnailSize: .md
                ),
                localAttributes: ParraAttributes.AsyncImage(
                    size: size,
                    cornerRadius: .full
                )
            )
        } elseRenderer: {
            componentFactory.buildImage(
                config: ParraImageConfig(),
                content: .symbol("person.crop.circle.fill", .hierarchical),
                localAttributes: ParraAttributes.Image(
                    size: size,
                    cornerRadius: .full
                )
            )
            .foregroundStyle(
                theme.palette.primary.toParraColor(),
                theme.palette.primaryBackground
            )
        }
    }

    // MARK: - Private

    @Environment(\.parraTheme) private var theme
    @Environment(\.parraComponentFactory) private var componentFactory
}
