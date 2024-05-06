//
//  EmptyStateConfig.swift
//  Parra
//
//  Created by Mick MacCallum on 3/13/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

public struct EmptyStateConfig: Equatable {
    // MARK: - Lifecycle

    public init(
        primaryAction: TextButtonConfig,
        secondaryAction: TextButtonConfig
    ) {
        self.primaryAction = primaryAction
        self.secondaryAction = secondaryAction
    }

    // MARK: - Public

    public static let defaultPrimaryAction = TextButtonConfig(
        style: .primary,
        size: .large,
        isMaxWidth: true
    )

    public static let defaultSecondaryAction = TextButtonConfig(
        style: .secondary,
        size: .medium,
        isMaxWidth: true
    )

    public static let `default` = EmptyStateConfig(
        primaryAction: defaultPrimaryAction,
        secondaryAction: defaultSecondaryAction
    )

    public static let errorDefault = EmptyStateConfig(
        primaryAction: TextButtonConfig(
            style: .primary,
            size: .large,
            isMaxWidth: true
        ),
        secondaryAction: TextButtonConfig(
            style: .secondary,
            size: .medium,
            isMaxWidth: true
        )
    )

    public let primaryAction: TextButtonConfig
    public let secondaryAction: TextButtonConfig
}
