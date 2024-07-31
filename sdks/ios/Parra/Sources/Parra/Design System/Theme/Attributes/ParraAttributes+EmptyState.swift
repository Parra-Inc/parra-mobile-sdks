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

        public internal(set) var titleLabel: ParraAttributes.Label
        public internal(set) var subtitleLabel: ParraAttributes.Label
        public internal(set) var icon: ParraAttributes.Image
        public internal(set) var primaryActionButton: ParraAttributes
            .ContainedButton
        public internal(set) var secondaryActionButton: ParraAttributes
            .PlainButton
        public internal(set) var tint: Color?
        public internal(set) var padding: ParraPaddingSize?
        public internal(set) var background: Color?
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
