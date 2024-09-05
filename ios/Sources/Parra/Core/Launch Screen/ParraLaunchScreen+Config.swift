//
//  ParraLaunchScreen+Config.swift
//  Parra
//
//  Created by Mick MacCallum on 2/14/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Foundation

public extension ParraLaunchScreen {
    struct Options: Equatable {
        // MARK: - Lifecycle

        /// - Parameters:
        ///   - type: The type of launch screen that should be displayed
        ///   while Parra is being initialized. This should match up exactly with
        ///   the launch screen that you have configured in your project settings to
        ///   avoid any sharp transitions. If nothing is provided, we will attempt
        ///   to display the right launch screen automatically. This is done by
        ///   checking for a `UILaunchScreen` key in your Info.plist file. If an
        ///   entry is found, its child values will be used to layout the launch
        ///   screen. Next we look for the `UILaunchStoryboardName` key. If this is
        ///   not found, a blank white screen will be rendered.
        ///   - fadeDuration: The duration, in seconds, that the launch screen
        ///   will take to fade away, revealing your app's content.
        public init(
            type: ParraLaunchScreenType,
            fadeDuration: TimeInterval = Options.defaultFadeDuration
        ) {
            self.type = type
            self.fadeDuration = fadeDuration
        }

        // MARK: - Public

        public static let defaultFadeDuration: TimeInterval = 0.5

        /// The type of launch screen that should be displayed while Parra is
        /// being initialized. This should match up exactly with the launch
        /// screen that you have configured in your project settings to avoid
        /// any sharp transitions. If nothing is provided, we will attempt to
        /// display the right launch screen automatically. This is done by
        /// checking for a `UILaunchScreen` key in your Info.plist file. If an
        /// entry is found, its child values will be used to layout the
        /// launch screen. Next we look for the `UILaunchStoryboardName` key.
        /// If this is not found, a blank white screen will be rendered.
        public let type: ParraLaunchScreenType

        /// The duration, in seconds, that the launch screen will take to fade
        /// away, revealing your app's content.
        public let fadeDuration: TimeInterval
    }
}
