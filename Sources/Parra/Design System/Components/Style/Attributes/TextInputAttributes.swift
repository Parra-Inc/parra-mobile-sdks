//
//  TextInputAttributes.swift
//  Parra
//
//  Created by Mick MacCallum on 2/20/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

public struct TextInputAttributes: ParraStyleAttributes {
    // MARK: - Lifecycle

    public init(
        title: LabelAttributes? = nil,
        helper: LabelAttributes? = nil,
        background: (any ShapeStyle)? = nil,
        cornerRadius: ParraCornerRadiusSize? = nil,
        font: Font? = nil,
        fontColor: ParraColorConvertible? = nil,
        fontDesign: Font.Design? = nil,
        fontWeight: Font.Weight? = nil,
        fontWidth: Font.Width? = nil,
        padding: EdgeInsets? = nil,
        keyboardType: UIKeyboardType = .default,
        textCase: Text.Case? = nil,
        textContentType: UITextContentType? = nil,
        textInputAutocapitalization: TextInputAutocapitalization? = nil,
        autocorrectionDisabled: Bool = true
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
        self.keyboardType = keyboardType
        self.textCase = textCase
        self.textContentType = textContentType
        self.textInputAutocapitalization = textInputAutocapitalization
        self.autocorrectionDisabled = autocorrectionDisabled
        self.frame = nil
        self.borderWidth = nil
        self.borderColor = nil
    }

    init(
        title: LabelAttributes? = nil,
        helper: LabelAttributes? = nil,
        background: (any ShapeStyle)? = nil,
        cornerRadius: ParraCornerRadiusSize? = nil,
        font: Font? = nil,
        fontColor: ParraColorConvertible? = nil,
        fontDesign: Font.Design? = nil,
        fontWeight: Font.Weight? = nil,
        fontWidth: Font.Width? = nil,
        padding: EdgeInsets? = nil,
        keyboardType: UIKeyboardType = .default,
        textCase: Text.Case? = nil,
        textContentType: UITextContentType? = nil,
        textInputAutocapitalization: TextInputAutocapitalization? = nil,
        autocorrectionDisabled: Bool = true,
        frame: FrameAttributes? = nil,
        borderWidth: CGFloat? = nil,
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
        self.keyboardType = keyboardType
        self.textCase = textCase
        self.textContentType = textContentType
        self.textInputAutocapitalization = textInputAutocapitalization
        self.autocorrectionDisabled = autocorrectionDisabled
        self.frame = frame
        self.borderWidth = borderWidth
        self.borderColor = borderColor
    }

    // MARK: - Public

    /// Attributes to use on the optional title label shown above the menu.
    public let title: LabelAttributes?

    /// Attributes to use on the optional helper field shown below the menu.
    public let helper: LabelAttributes?

    public let background: (any ShapeStyle)?
    public let cornerRadius: ParraCornerRadiusSize?
    public let font: Font?
    public let fontColor: Color?
    public let fontDesign: Font.Design?
    public let fontWeight: Font.Weight?
    public let fontWidth: Font.Width?
    public let padding: EdgeInsets?

    public let keyboardType: UIKeyboardType
    public let textCase: Text.Case?
    public let textContentType: UITextContentType?
    public let textInputAutocapitalization: TextInputAutocapitalization?
    public let autocorrectionDisabled: Bool

    // MARK: - Internal

    let frame: FrameAttributes?
    let borderWidth: CGFloat?
    let borderColor: Color?
}
