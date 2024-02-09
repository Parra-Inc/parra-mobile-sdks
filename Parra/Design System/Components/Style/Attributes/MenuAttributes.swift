//
//  MenuAttributes.swift
//  Parra
//
//  Created by Mick MacCallum on 2/5/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

public struct MenuAttributes: ParraStyleAttributes {
    // MARK: - Lifecycle

    public init(
        title: LabelAttributes,
        helper: LabelAttributes,
        menuItem: LabelAttributes,
        menuItemSelected: LabelAttributes,
        sortOrder: MenuOrder = .fixed,
        tint: Color? = nil,
        background: (any ShapeStyle)? = nil,
        cornerRadius: ParraCornerRadiusSize? = nil,
        padding: EdgeInsets? = nil
    ) {
        self.init(
            title: title,
            helper: helper,
            menuItem: menuItem,
            menuItemSelected: menuItemSelected,
            sortOrder: sortOrder,
            tint: tint,
            background: background,
            cornerRadius: cornerRadius,
            padding: padding,
            frame: nil,
            borderWidth: 0
        )
    }

    init(
        title: LabelAttributes,
        helper: LabelAttributes,
        menuItem: LabelAttributes,
        menuItemSelected: LabelAttributes,
        sortOrder: MenuOrder = .fixed,
        tint: Color? = nil,
        background: (any ShapeStyle)? = nil,
        cornerRadius: ParraCornerRadiusSize? = nil,
        padding: EdgeInsets? = nil,
        frame: FrameAttributes? = nil,
        borderWidth: CGFloat = 0
    ) {
        self.title = title
        self.helper = helper
        self.menuItem = menuItem
        self.menuItemSelected = menuItemSelected
        self.sortOrder = sortOrder
        self.tint = tint
        self.background = background
        self.cornerRadius = cornerRadius
        self.padding = padding
        self.frame = frame
        self.borderWidth = borderWidth
    }

    // MARK: - Public

    /// Attributes to use on the optional title label shown above the menu.
    public let title: LabelAttributes

    /// Attributes to use on the optional helper field shown below the menu.
    public let helper: LabelAttributes

    /// Attributes to use on the label shown when the menu is collapsed and a selection has not been made yet.
    public let menuItem: LabelAttributes

    /// Attributes to use on the label shown when the menu is collapsed and a selection has been made.
    public let menuItemSelected: LabelAttributes

    public let sortOrder: MenuOrder

    public let tint: Color?

    public let background: (any ShapeStyle)?
    public let cornerRadius: ParraCornerRadiusSize?
    public let padding: EdgeInsets?

    // MARK: - Internal

    let frame: FrameAttributes?
    let borderWidth: CGFloat
}
