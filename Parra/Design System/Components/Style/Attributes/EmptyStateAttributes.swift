//
//  EmptyStateAttributes.swift
//  Parra
//
//  Created by Mick MacCallum on 3/13/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

public struct EmptyStateAttributes: ParraStyleAttributes {
    // MARK: - Lifecycle

    public init(
        title: LabelAttributes = LabelAttributes(),
        subtitle: LabelAttributes = .init(),
        icon: ImageAttributes = .init(),
        primaryAction: TextButtonAttributes = .init(),
        secondaryAction: TextButtonAttributes = .init(),
        background: (any ShapeStyle)? = nil,
        padding: EdgeInsets? = nil
    ) {
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
        self.primaryAction = primaryAction
        self.secondaryAction = secondaryAction
        self.background = background
        self.padding = padding
    }

    // MARK: - Public

    public let title: LabelAttributes
    public let subtitle: LabelAttributes
    public let icon: ImageAttributes
    public let primaryAction: TextButtonAttributes
    public let secondaryAction: TextButtonAttributes

    public let background: (any ShapeStyle)?
    public let padding: EdgeInsets?

    // MARK: - Internal

    func withUpdates(
        updates: EmptyStateAttributes?
    ) -> EmptyStateAttributes {
        return EmptyStateAttributes(
            title: title.withUpdates(updates: updates?.title),
            subtitle: subtitle.withUpdates(updates: updates?.subtitle),
            icon: icon.withUpdates(updates: updates?.icon),
            primaryAction: primaryAction
                .withUpdates(updates: updates?.primaryAction),
            secondaryAction: secondaryAction
                .withUpdates(updates: updates?.secondaryAction),
            background: updates?.background ?? background,
            padding: updates?.padding ?? padding
        )
    }
}
