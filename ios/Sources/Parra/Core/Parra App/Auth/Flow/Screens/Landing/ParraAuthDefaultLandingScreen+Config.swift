//
//  ParraAuthDefaultLandingScreen+Config.swift
//  Parra
//
//  Created by Mick MacCallum on 6/11/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

public extension ParraAuthDefaultLandingScreen {
    struct Config: ParraAuthScreenConfig {
        // MARK: - Lifecycle

        public init(
            background: (any ShapeStyle)?,
            logoView: (any View)?,
            titleView: (any View)?,
            bottomView: (any View)?
        ) {
            self.background = background
            self.logoView = logoView
            self.titleView = titleView
            self.bottomView = bottomView
        }

        // MARK: - Public

        public static let `default` = Config(
            background: nil,
            logoView: nil,
            titleView: nil,
            bottomView: nil
        )

        public let background: (any ShapeStyle)?

        /// A view to be displayed on the top portion of the screen with a logo
        /// for the app. The default pulls the logo image from your tenant in
        /// the Parra dashboard.
        public let logoView: (any View)?

        /// A view to be displayed on the top portion of the screen, beneath the
        /// logo view. By default, this shows labels for your app name and a
        /// subtitle.
        public let titleView: (any View)?

        /// A view to be displayed on the bottom portion of the screen, below
        /// any buttons for login methods. By default, this is an EmptyView.
        public let bottomView: (any View)?

        // MARK: - Internal

        static func defaultWith(
            title: String,
            subtitle: String,
            using theme: ParraTheme,
            componentFactory: ParraComponentFactory,
            appInfo: ParraAppInfo
        ) -> Config {
            return Config(
                background: theme.palette.primaryBackground.toParraColor(),
                logoView: {
                    if let logo = appInfo.tenant.logo {
                        componentFactory.buildAsyncImage(
                            content: ParraAsyncImageContent(
                                logo,
                                preferredThumbnailSize: .lg
                            ),
                            localAttributes: ParraAttributes.AsyncImage(
                                size: CGSize(width: 200, height: 200),
                                padding: .zero
                            )
                        )
                    } else {
                        EmptyView()
                    }
                }(),
                titleView: Group {
                    componentFactory.buildLabel(
                        content: ParraLabelContent(
                            text: title
                        ),
                        localAttributes: ParraAttributes.Label(
                            text: ParraAttributes.Text(
                                font: .systemFont(ofSize: 50, weight: .heavy),
                                alignment: .center
                            ),
                            padding: .md
                        )
                    )
                    .minimumScaleFactor(0.5)
                    .lineLimit(2)

                    componentFactory.buildLabel(
                        content: ParraLabelContent(text: subtitle),
                        localAttributes: ParraAttributes.Label(
                            text: .default(with: .subheadline),
                            padding: .zero
                        )
                    )
                },
                bottomView: nil
            )
        }
    }
}
