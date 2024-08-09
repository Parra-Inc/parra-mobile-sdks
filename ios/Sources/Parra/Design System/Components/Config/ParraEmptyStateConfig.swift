//
//  ParraEmptyStateConfig.swift
//  Parra
//
//  Created by Mick MacCallum on 3/13/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

public struct ParraEmptyStateConfig: Equatable {
    // MARK: - Lifecycle

    public init(
        primaryAction: ParraTextButtonConfig,
        secondaryAction: ParraTextButtonConfig
    ) {
        self.primaryAction = primaryAction
        self.secondaryAction = secondaryAction
    }

    // MARK: - Public

    public static let defaultPrimaryAction = ParraTextButtonConfig(
        type: .primary,
        size: .large,
        isMaxWidth: true
    )

    public static let defaultSecondaryAction = ParraTextButtonConfig(
        type: .secondary,
        size: .medium,
        isMaxWidth: true
    )

    public static let `default` = ParraEmptyStateConfig(
        primaryAction: defaultPrimaryAction,
        secondaryAction: defaultSecondaryAction
    )

    public static let errorDefault = ParraEmptyStateConfig(
        primaryAction: ParraTextButtonConfig(
            type: .primary,
            size: .large,
            isMaxWidth: true
        ),
        secondaryAction: ParraTextButtonConfig(
            type: .secondary,
            size: .medium,
            isMaxWidth: true
        )
    )

    public let primaryAction: ParraTextButtonConfig
    public let secondaryAction: ParraTextButtonConfig
}
