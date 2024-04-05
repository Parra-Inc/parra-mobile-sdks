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
        title: LabelConfig = EmptyStateConfig.default.title,
        subtitle: LabelConfig = EmptyStateConfig.default.subtitle,
        primaryAction: TextButtonConfig,
        secondaryAction: TextButtonConfig
    ) {
        self.title = title
        self.subtitle = subtitle
        self.primaryAction = primaryAction
        self.secondaryAction = secondaryAction
    }

    // MARK: - Public

    public static let `default` = EmptyStateConfig(
        title: LabelConfig(fontStyle: .title),
        subtitle: LabelConfig(fontStyle: .body),
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

    public static let errorDefault = EmptyStateConfig(
        title: LabelConfig(fontStyle: .title2),
        subtitle: LabelConfig(fontStyle: .body),
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

    public let title: LabelConfig
    public let subtitle: LabelConfig
    public let primaryAction: TextButtonConfig
    public let secondaryAction: TextButtonConfig
}
