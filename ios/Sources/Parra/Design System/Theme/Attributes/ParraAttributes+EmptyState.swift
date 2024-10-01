//
//  ParraAttributes+EmptyState.swift
//  Parra
//
//  Created by Mick MacCallum on 5/14/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

// MARK: - ParraAttributes.EmptyState

public extension ParraAttributes {
    struct EmptyState {
        // MARK: - Lifecycle

        public init(
            titleLabel: ParraAttributes.Label = .default(with: .headline),
            subtitleLabel: ParraAttributes.Label = .default(with: .subheadline),
            icon: ParraAttributes.Image = .init(),
            primaryActionButton: ParraAttributes.ContainedButton = .init(),
            secondaryActionButton: ParraAttributes.PlainButton = .init(),
            tint: Color? = nil,
            padding: ParraPaddingSize? = nil,
            background: Color? = nil
        ) {
            self.titleLabel = titleLabel
            self.subtitleLabel = subtitleLabel
            self.icon = icon
            self.primaryActionButton = primaryActionButton
            self.secondaryActionButton = secondaryActionButton
            self.tint = tint
            self.padding = padding
            self.background = background
        }

        // MARK: - Public

        public var titleLabel: ParraAttributes.Label
        public var subtitleLabel: ParraAttributes.Label
        public var icon: ParraAttributes.Image
        public var primaryActionButton: ParraAttributes
            .ContainedButton
        public var secondaryActionButton: ParraAttributes
            .PlainButton
        public var tint: Color?
        public var padding: ParraPaddingSize?
        public var background: Color?
    }
}

// MARK: - ParraAttributes.EmptyState + OverridableAttributes

extension ParraAttributes.EmptyState: OverridableAttributes {
    func mergingOverrides(
        _ overrides: ParraAttributes.EmptyState?
    ) -> ParraAttributes.EmptyState {
        return ParraAttributes.EmptyState(
            titleLabel: titleLabel.mergingOverrides(overrides?.titleLabel),
            subtitleLabel: subtitleLabel
                .mergingOverrides(overrides?.subtitleLabel),
            icon: icon.mergingOverrides(overrides?.icon),
            primaryActionButton: primaryActionButton
                .mergingOverrides(overrides?.primaryActionButton),
            secondaryActionButton: secondaryActionButton
                .mergingOverrides(overrides?.secondaryActionButton),
            tint: overrides?.tint ?? tint,
            padding: overrides?.padding ?? padding,
            background: overrides?.background ?? background
        )
    }
}
