//
//  MenuAttributes.swift
//  Parra
//
//  Created by Mick MacCallum on 2/5/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

public struct MenuAttributes: ParraStyleAttributes {
    /// Attributes to use on the label shown when the menu is collapsed and a selection has not been made yet.
    public let label: LabelAttributes

    /// Attributes to use on the label shown when the menu is collapsed and a selection has been made.
    public let labelWithSelection: LabelAttributes?

    public let sortOrder: MenuOrder

    public let tint: Color?

    public let background: (any ShapeStyle)?
    public let cornerRadius: RectangleCornerRadii?
    public let padding: EdgeInsets?

    internal let frame: FrameAttributes?
    internal let borderWidth: CGFloat

    public init(
        label: LabelAttributes,
        labelWithSelection: LabelAttributes? = nil,
        sortOrder: MenuOrder = .fixed,
        tint: Color? = nil,
        background: (any ShapeStyle)? = nil,
        cornerRadius: RectangleCornerRadii? = nil,
        padding: EdgeInsets? = nil
    ) {
        self.init(
            label: label,
            labelWithSelection: labelWithSelection,
            sortOrder: sortOrder,
            tint: tint,
            background: background,
            cornerRadius: cornerRadius,
            padding: padding,
            frame: nil,
            borderWidth: 0
        )
    }

    internal init(
        label: LabelAttributes,
        labelWithSelection: LabelAttributes? = nil,
        sortOrder: MenuOrder = .fixed,
        tint: Color? = nil,
        background: (any ShapeStyle)? = nil,
        cornerRadius: RectangleCornerRadii? = nil,
        padding: EdgeInsets? = nil,
        frame: FrameAttributes? = nil,
        borderWidth: CGFloat = 0
    ) {
        self.label = label
        self.labelWithSelection = labelWithSelection
        self.sortOrder = sortOrder
        self.tint = tint
        self.background = background
        self.cornerRadius = cornerRadius
        self.padding = padding
        self.frame = frame
        self.borderWidth = borderWidth
    }
}
