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
        showLoadingIndicator: Bool = true,
        showVerifiedBadge: Bool = false
    ) {
        self.avatar = avatar
        self.size = size
        self.showLoadingIndicator = showLoadingIndicator
        self.showVerifiedBadge = showVerifiedBadge
    }

    // MARK: - Internal

    var avatar: ParraImageAsset?
    var size: CGSize
    var showLoadingIndicator: Bool
    var showVerifiedBadge: Bool

    var body: some View {
        withContent(
            content: avatar
        ) { avatar in
            ZStack(alignment: .topTrailing) {
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

                if showBadge {
                    ZStack(alignment: .center) {
                        Color.white
                            .applyCornerRadii(size: .full, from: theme)
                            .frame(
                                width: size.width / 4,
                                height: size.height / 4,
                                alignment: .center
                            )

                        componentFactory.buildImage(
                            content: .name("CheckBadgeSolid", .module, .template),
                            localAttributes: ParraAttributes.Image(
                                tint: .blue,
                                size: CGSize(
                                    width: size.width / 2,
                                    height: size.height / 2
                                ),
                                padding: .zero
                            )
                        )
                    }
                    .offset(
                        x: size.width / 8,
                        y: -size.height / 8
                    )
                }
            }
            .padding(.top, showBadge ? size.height / 8 : 0)
            .padding(.trailing, showBadge ? size.width / 8 : 0)
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
    @Environment(\.redactionReasons) private var redactionReasons

    private var showBadge: Bool {
        return showVerifiedBadge && !redactionReasons.contains(.placeholder)
    }
}
