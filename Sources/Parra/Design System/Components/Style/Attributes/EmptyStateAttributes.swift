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
        icon: ParraAttributes.Image = .init(),
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
    public let icon: ParraAttributes.Image
    public let primaryAction: TextButtonAttributes
    public let secondaryAction: TextButtonAttributes

    public let background: (any ShapeStyle)?
    public let padding: EdgeInsets?
}
