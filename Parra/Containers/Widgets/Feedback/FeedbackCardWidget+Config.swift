//
//  FeedbackCardWidget+Config.swift
//  Parra
//
//  Created by Mick MacCallum on 2/21/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

extension FeedbackCardWidget {
    struct Config: ContainerConfig {
        static let `default` = Config(
            backButton: ButtonConfig(style: .primary, size: .small),
            forwardButton: ButtonConfig(style: .primary, size: .small)
        )

        let backButton: ButtonConfig
        let forwardButton: ButtonConfig
    }
}
