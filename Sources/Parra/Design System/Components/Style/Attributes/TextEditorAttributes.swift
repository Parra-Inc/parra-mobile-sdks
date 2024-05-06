//
//  TextEditorAttributes.swift
//  Parra
//
//  Created by Mick MacCallum on 2/5/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

public struct TextEditorAttributes: ParraStyleAttributes {
    // MARK: - Lifecycle

    public init(
        title: LabelAttributes,
        helper: LabelAttributes,
        background: (any ShapeStyle)? = nil,
        cornerRadius: ParraCornerRadiusSize? = nil,
        font: Font? = nil,
        fontColor: ParraColorConvertible? = nil,
        fontDesign: Font.Design? = nil,
        fontWeight: Font.Weight? = nil,
        fontWidth: Font.Width? = nil,
        padding: EdgeInsets? = nil
    ) {
        self.title = title
        self.helper = helper
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

    init(
        title: LabelAttributes,
        helper: LabelAttributes,
        background: (any ShapeStyle)? = nil,
        cornerRadius: ParraCornerRadiusSize? = nil,
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
        self.title = title
        self.helper = helper
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

    // MARK: - Public

    /// Attributes to use on the optional title label shown above the menu.
    public let title: LabelAttributes

    /// Attributes to use on the optional helper field shown below the menu.
    public let helper: LabelAttributes

    public let background: (any ShapeStyle)?
    public let cornerRadius: ParraCornerRadiusSize?
    public let font: Font?
    public let fontColor: Color?
    public let fontDesign: Font.Design?
    public let fontWeight: Font.Weight?
    public let fontWidth: Font.Width?
    public let padding: EdgeInsets?

    // MARK: - Internal

    let frame: FrameAttributes?
    let borderWidth: CGFloat
    let borderColor: Color?
}
