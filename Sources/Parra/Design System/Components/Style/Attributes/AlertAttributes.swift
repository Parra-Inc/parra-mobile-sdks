//
//  AlertAttributes.swift
//  Parra
//
//  Created by Mick MacCallum on 3/7/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

public struct AlertAttributes: ParraStyleAttributes {
    // MARK: - Lifecycle

    public init(
        title: LabelAttributes = .init(),
        subtitle: LabelAttributes = .init(),
        icon: ParraAttributes.Image = .init(),
//        dismiss: ImageButtonAttributes = .init(image: .init()),
        background: (any ShapeStyle)? = nil,
        cornerRadius: ParraCornerRadiusSize? = nil,
        padding: EdgeInsets? = nil,
        borderWidth: CGFloat? = nil,
        borderColor: Color? = nil
    ) {
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
//        self.dismiss = dismiss
        self.background = background
        self.cornerRadius = cornerRadius
        self.padding = padding
        self.borderWidth = borderWidth
        self.borderColor = borderColor
    }

    // MARK: - Public

    public let title: LabelAttributes
    public let subtitle: LabelAttributes
    public let icon: ParraAttributes.Image
//    public let dismiss: ImageButtonAttributes

    public let background: (any ShapeStyle)?
    public let cornerRadius: ParraCornerRadiusSize?
    public let padding: EdgeInsets?
    public let borderWidth: CGFloat?
    public let borderColor: Color?

    // MARK: - Internal
}
