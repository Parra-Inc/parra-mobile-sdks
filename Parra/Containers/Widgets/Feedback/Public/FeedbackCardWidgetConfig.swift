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
        titleLabel: LabelConfig,
        subtitleLabel: LabelConfig,
        booleanOptions: ButtonConfig,
        choiceOptions: ButtonConfig,
        checkboxOptions: ButtonConfig
    ) {
        self.backButton = backButton
        self.forwardButton = forwardButton
        self.titleLabel = titleLabel
        self.subtitleLabel = subtitleLabel
        self.booleanOptions = booleanOptions
        self.choiceOptions = choiceOptions
        self.checkboxOptions = checkboxOptions
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
        titleLabel: LabelConfig(fontStyle: .headline),
        subtitleLabel: LabelConfig(fontStyle: .subheadline),
        booleanOptions: ButtonConfig(
            style: .primary,
            size: .medium,
            isMaxWidth: true
        ),
        choiceOptions: ButtonConfig(
            style: .primary,
            size: .medium,
            isMaxWidth: true
        ),
        checkboxOptions: ButtonConfig(
            style: .primary,
            size: .medium,
            isMaxWidth: true
        )
    )

    public let backButton: ButtonConfig
    public let forwardButton: ButtonConfig

    public let titleLabel: LabelConfig
    public let subtitleLabel: LabelConfig

    public let booleanOptions: ButtonConfig
    public let choiceOptions: ButtonConfig
    public let checkboxOptions: ButtonConfig
}
