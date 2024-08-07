//
//  ParraLaunchScreen+Config.swift
//  Parra
//
//  Created by Mick MacCallum on 2/14/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Foundation

public extension ParraLaunchScreen {
    struct Config: Equatable {
        // MARK: - Lifecycle

        public init(
            type: ParraLaunchScreenType,
            fadeDuration: CGFloat = Config.defaultFadeDuration
        ) {
            self.type = type
            self.fadeDuration = fadeDuration
        }

        // MARK: - Public

        public static let defaultFadeDuration: CGFloat = 0.5

        public let type: ParraLaunchScreenType
        public let fadeDuration: CGFloat
    }
}
