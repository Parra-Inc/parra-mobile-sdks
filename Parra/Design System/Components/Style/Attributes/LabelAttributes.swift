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
        iconAttributes: ImageAttributes? = nil
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
        iconAttributes: ImageAttributes? = nil,
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
    public let iconAttributes: ImageAttributes?

    // MARK: - Internal

    let frame: FrameAttributes?
    let borderWidth: CGFloat?
    let borderColor: Color?

    static func defaultFormTitle(
        in theme: ParraTheme,
        with config: LabelConfig
    ) -> LabelAttributes {
        return LabelComponent.applyStandardCustomizations(
            onto: LabelAttributes(
                fontColor: theme.palette.primaryText.toParraColor(),
                fontWeight: .medium,
                padding: EdgeInsets(top: 0, leading: 0, bottom: 10, trailing: 2)
            ),
            theme: theme,
            config: config
        )
    }

    static func defaultFormHelper(
        in theme: ParraTheme,
        with config: LabelConfig,
        erroring: Bool = false
    ) -> LabelAttributes {
        let fontColor = erroring
            ? theme.palette.error.toParraColor()
            : theme.palette.secondaryText.toParraColor()

        return LabelComponent.applyStandardCustomizations(
            onto: LabelAttributes(
                fontColor: fontColor,
                padding: EdgeInsets(top: 4, leading: 0, bottom: 0, trailing: 2),
                frame: .flexible(
                    FlexibleFrameAttributes(
                        maxWidth: .infinity,
                        alignment: .trailing
                    )
                )
            ),
            theme: theme,
            config: config
        )
    }

    static func defaultFormCallout(
        in theme: ParraTheme,
        with config: LabelConfig,
        erroring: Bool = false
    ) -> LabelAttributes {
        let fontColor = erroring
            ? theme.palette.error.toParraColor()
            : theme.palette.secondaryText.toParraColor()

        return LabelComponent.applyStandardCustomizations(
            onto: LabelAttributes(
                fontColor: fontColor.opacity(0.8)
            ),
            theme: theme,
            config: config
        )
    }

    func withUpdates(
        updates: LabelAttributes?
    ) -> LabelAttributes {
        return LabelAttributes(
            background: updates?.background ?? background,
            cornerRadius: updates?.cornerRadius ?? cornerRadius,
            font: updates?.font ?? font,
            fontColor: updates?.fontColor ?? fontColor,
            fontDesign: updates?.fontDesign ?? fontDesign,
            fontWeight: updates?.fontWeight ?? fontWeight,
            fontWidth: updates?.fontWidth ?? fontWidth,
            padding: updates?.padding ?? padding,
            layoutDirectionBehavior: updates?
                .layoutDirectionBehavior ?? layoutDirectionBehavior,
            iconAttributes: iconAttributes?.withUpdates(
                updates: updates?.iconAttributes
            ) ?? updates?.iconAttributes,
            frame: updates?.frame ?? frame,
            borderWidth: updates?.borderWidth ?? borderWidth,
            borderColor: updates?.borderColor ?? borderColor
        )
    }
}
