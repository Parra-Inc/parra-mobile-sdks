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
        backButton: ImageButtonConfig,
        forwardButton: ImageButtonConfig,
        titleLabel: LabelConfig,
        subtitleLabel: LabelConfig,
        booleanOptions: TextButtonConfig,
        choiceOptions: TextButtonConfig,
        checkboxOptions: TextButtonConfig
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
        backButton: ImageButtonConfig(
            style: .primary,
            size: .smallSquare
        ),
        forwardButton: ImageButtonConfig(
            style: .primary,
            size: .smallSquare
        ),
        titleLabel: LabelConfig(fontStyle: .headline),
        subtitleLabel: LabelConfig(fontStyle: .subheadline),
        booleanOptions: TextButtonConfig(
            style: .primary,
            size: .medium,
            isMaxWidth: true
        ),
        choiceOptions: TextButtonConfig(
            style: .primary,
            size: .medium,
            isMaxWidth: true
        ),
        checkboxOptions: TextButtonConfig(
            style: .primary,
            size: .medium,
            isMaxWidth: true
        )
    )

    public let backButton: ImageButtonConfig
    public let forwardButton: ImageButtonConfig

    public let titleLabel: LabelConfig
    public let subtitleLabel: LabelConfig

    public let booleanOptions: TextButtonConfig
    public let choiceOptions: TextButtonConfig
    public let checkboxOptions: TextButtonConfig
}
