//
//  FeedbackCardWidgetConfig.swift
//  Parra
//
//  Created by Mick MacCallum on 2/21/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

public struct FeedbackCardWidgetConfig: ContainerConfig {
    public static let `default` = FeedbackCardWidgetConfig(
        backButton: ButtonConfig(style: .primary, size: .small),
        forwardButton: ButtonConfig(style: .primary, size: .small)
    )

    public let backButton: ButtonConfig
    public let forwardButton: ButtonConfig
}
