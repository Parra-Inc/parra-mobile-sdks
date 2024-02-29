//
//  FeedbackCardWidgetConfig.swift
//  Parra
//
//  Created by Mick MacCallum on 2/21/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

public class FeedbackCardWidgetConfig: ContainerConfig, Observable {
    // MARK: - Lifecycle

    public init(
        backButton: ButtonConfig,
        forwardButton: ButtonConfig,
        booleanOptions: ButtonConfig
    ) {
        self.backButton = backButton
        self.forwardButton = forwardButton
        self.booleanOptions = booleanOptions
    }

    // MARK: - Public

    public static let `default` = FeedbackCardWidgetConfig(
        backButton: ButtonConfig(
            style: .primary,
            size: .small
        ),
        forwardButton: ButtonConfig(
            style: .primary,
            size: .small
        ),
        booleanOptions: ButtonConfig(
            style: .primary,
            size: .medium,
            isMaxWidth: true
        )
    )

    public let backButton: ButtonConfig
    public let forwardButton: ButtonConfig

    public let booleanOptions: ButtonConfig
}
