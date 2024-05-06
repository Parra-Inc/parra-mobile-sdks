//
//  LabelAttributes.swift
//  Parra
//
//  Created by Mick MacCallum on 1/28/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

public struct LabelAttributes: ParraStyleAttributes {
    // MARK: - Lifecycle

    public init(
        background: (any ShapeStyle)? = nil,
        cornerRadius: ParraCornerRadiusSize? = nil,
        font: Font? = nil,
        fontColor: ParraColorConvertible? = nil,
        fontDesign: Font.Design? = nil,
        fontWeight: Font.Weight? = nil,
        fontWidth: Font.Width? = nil,
        padding: EdgeInsets? = nil,
        layoutDirectionBehavior: LayoutDirectionBehavior? = nil,
        iconAttributes: ParraAttributes.Image? = nil
    ) {
        self.background = background
        self.cornerRadius = cornerRadius
        self.font = font
        self.fontColor = fontColor?.toParraColor()
        self.fontDesign = fontDesign
        self.fontWeight = fontWeight
        self.fontWidth = fontWidth
        self.padding = padding
        self.layoutDirectionBehavior = layoutDirectionBehavior
        self.iconAttributes = iconAttributes
        self.frame = nil
        self.borderWidth = nil
        self.borderColor = nil
    }

    init(
        background: (any ShapeStyle)? = nil,
        cornerRadius: ParraCornerRadiusSize? = nil,
        font: Font? = nil,
        fontColor: ParraColorConvertible? = nil,
        fontDesign: Font.Design? = nil,
        fontWeight: Font.Weight? = nil,
        fontWidth: Font.Width? = nil,
        padding: EdgeInsets? = nil,
        layoutDirectionBehavior: LayoutDirectionBehavior? = nil,
        iconAttributes: ParraAttributes.Image? = nil,
        frame: FrameAttributes? = nil,
        borderWidth: CGFloat? = nil,
        borderColor: Color? = nil
    ) {
        self.background = background
        self.cornerRadius = cornerRadius
        self.font = font
        self.fontColor = fontColor?.toParraColor()
        self.fontDesign = fontDesign
        self.fontWeight = fontWeight
        self.fontWidth = fontWidth
        self.padding = padding
        self.layoutDirectionBehavior = layoutDirectionBehavior
        self.iconAttributes = iconAttributes
        self.frame = frame
        self.borderWidth = borderWidth
        self.borderColor = borderColor
    }

    // MARK: - Public

    public let background: (any ShapeStyle)?
    public let cornerRadius: ParraCornerRadiusSize?
    public let font: Font?
    public let fontColor: Color?
    public let fontDesign: Font.Design?
    public let fontWeight: Font.Weight?
    public let fontWidth: Font.Width?
    public let padding: EdgeInsets?
    public let layoutDirectionBehavior: LayoutDirectionBehavior?
    public let iconAttributes: ParraAttributes.Image?

    // MARK: - Internal

    let frame: FrameAttributes?
    let borderWidth: CGFloat?
    let borderColor: Color?
}
