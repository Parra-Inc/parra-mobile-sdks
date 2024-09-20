//
//  ParraAuthDefaultIdentityInputScreen+Config.swift
//  Parra
//
//  Created by Mick MacCallum on 6/11/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

public extension ParraAuthDefaultIdentityInputScreen {
    struct Config: ParraAuthScreenConfig {
        // MARK: - Lifecycle

        public init(
            background: (any ShapeStyle)?,
            topView: (any View)?,
            bottomView: (any View)?
        ) {
            self.background = background
            self.topView = topView
            self.bottomView = bottomView
        }

        // MARK: - Public

        public static var `default` = Config(
            background: nil,
            topView: nil,
            bottomView: nil
        )

        public let background: (any ShapeStyle)?

        /// A view to be displayed on the top portion of the screen, replacing
        /// Parra's default login method description label.
        public let topView: (any View)?

        /// A view to be displayed on the bottom portion of the screen, below
        /// any inputs for login methods. By default, this is a Spacer.
        public let bottomView: (any View)?
    }
}
