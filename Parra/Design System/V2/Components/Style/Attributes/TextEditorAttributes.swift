//
//  TextEditorAttributes.swift
//  Parra
//
//  Created by Mick MacCallum on 2/5/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

public struct TextEditorAttributes: ParraStyleAttributes {
    public let background: (any ShapeStyle)?
    public let cornerRadius: RectangleCornerRadii?
    public let font: Font?
    public let fontColor: Color?
    public let fontDesign: Font.Design?
    public let fontWeight: Font.Weight?
    public let fontWidth: Font.Width?
    public let padding: EdgeInsets?

    internal let frame: FrameAttributes?
    internal let borderWidth: CGFloat
    internal let borderColor: Color?

    public init(
        background: (any ShapeStyle)? = nil,
        cornerRadius: RectangleCornerRadii? = nil,
        font: Font? = nil,
        fontColor: ParraColorConvertible? = nil,
        fontDesign: Font.Design? = nil,
        fontWeight: Font.Weight? = nil,
        fontWidth: Font.Width? = nil,
        padding: EdgeInsets? = nil
    ) {
        self.background = background
        self.cornerRadius = cornerRadius
        self.font = font
        self.fontColor = fontColor?.toParraColor()
        self.fontDesign = fontDesign
        self.fontWeight = fontWeight
        self.fontWidth = fontWidth
        self.padding = padding
        self.frame = nil
        self.borderWidth = 0
        self.borderColor = nil
    }

    internal init(
        background: (any ShapeStyle)? = nil,
        cornerRadius: RectangleCornerRadii? = nil,
        font: Font? = nil,
        fontColor: ParraColorConvertible? = nil,
        fontDesign: Font.Design? = nil,
        fontWeight: Font.Weight? = nil,
        fontWidth: Font.Width? = nil,
        padding: EdgeInsets? = nil,
        frame: FrameAttributes? = nil,
        borderWidth: CGFloat = 0,
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
        self.frame = frame
        self.borderWidth = borderWidth
        self.borderColor = borderColor
    }

    internal func withUpdates(
        updates: TextEditorAttributes?
    ) -> TextEditorAttributes {
        return TextEditorAttributes(
            background: updates?.background ?? background,
            cornerRadius: updates?.cornerRadius ?? cornerRadius,
            font: updates?.font ?? font,
            fontColor: updates?.fontColor ?? fontColor,
            fontDesign: updates?.fontDesign ?? fontDesign,
            fontWeight: updates?.fontWeight ?? fontWeight,
            fontWidth: updates?.fontWidth ?? fontWidth,
            padding: updates?.padding ?? padding,
            frame: updates?.frame ?? frame,
            borderWidth: updates?.borderWidth ?? borderWidth,
            borderColor: updates?.borderColor ?? borderColor
        )
    }
}
