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
        public static var `default` = Config(
            background: nil,
            topView: nil,
            bottomView: nil
        )

        public let background: (any ShapeStyle)?

        /// A view to be displayed on the top portion of the screen, replacing
        /// Parra's default labels for your app name and a subtitle.
        public let topView: (any View)?

        /// A view to be displayed on the bottom portion of the screen, below
        /// any buttons for login methods. By default, this is an EmptyView.
        public let bottomView: (any View)?
    }
}
