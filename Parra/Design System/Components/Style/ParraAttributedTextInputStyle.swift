//
//  ParraAttributedTextInputStyle.swift
//  Parra
//
//  Created by Mick MacCallum on 2/20/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

struct ParraAttributedTextInputStyle: TextFieldStyle, ParraAttributedStyle {
    // MARK: - Lifecycle

    init(
        config: TextInputConfig,
        content: TextInputContent,
        attributes: TextInputAttributes,
        theme: ParraTheme
    ) {
        self.config = config
        self.content = content
        self.attributes = attributes
        self.theme = theme

        self.titleStyle = if let title = content.title {
            ParraAttributedLabelStyle(
                content: title,
                attributes: attributes.title,
                theme: theme
            )
        } else {
            nil
        }
        self.helperStyle = if let helper = content.helper {
            ParraAttributedLabelStyle(
                content: helper,
                attributes: attributes.helper,
                theme: theme
            )
        } else {
            nil
        }
    }

    // MARK: - Internal

    enum Constant {
        static let contentInsets = EdgeInsets(
            vertical: 4,
            horizontal: 8
        )

        static let primaryTextPadding = EdgeInsets(
            vertical: contentInsets.top + 8,
            horizontal: contentInsets.leading + 6
        )
    }

    let config: TextInputConfig
    let content: TextInputContent
    let attributes: TextInputAttributes
    let theme: ParraTheme

    let titleStyle: ParraAttributedLabelStyle?
    let helperStyle: ParraAttributedLabelStyle?

    @ViewBuilder
    func _body(configuration: TextField<Self._Label>) -> some View {
        let fontColor = attributes.fontColor
            ?? theme.palette.primaryText.toParraColor()

        configuration
            .tint(theme.palette.primary.toParraColor())
            .background(.clear)
            .contentMargins(
                .all,
                Constant.contentInsets,
                for: .automatic
            )
            .frame(
                minWidth: attributes.frame?.minWidth,
                idealWidth: attributes.frame?.idealWidth,
                maxWidth: attributes.frame?.maxWidth,
                minHeight: attributes.frame?.minHeight,
                idealHeight: attributes.frame?.idealHeight,
                maxHeight: attributes.frame?.maxHeight,
                alignment: attributes.frame?.alignment ?? .center
            )
            .foregroundStyle(fontColor)
            .padding()
            .overlay(
                UnevenRoundedRectangle(
                    cornerRadii: theme.cornerRadius
                        .value(for: attributes.cornerRadius)
                )
                .strokeBorder(
                    attributes.borderColor
                        ?? theme.palette.secondaryBackground,
                    lineWidth: attributes.borderWidth
                )
            )
            .font(attributes.font)
            .fontDesign(attributes.fontDesign)
            .fontWeight(attributes.fontWeight)
            .fontWidth(attributes.fontWidth)
            .keyboardType(attributes.keyboardType)
            .textCase(attributes.textCase)
            .textContentType(attributes.textContentType)
            .textInputAutocapitalization(attributes.textInputAutocapitalization)
            .autocorrectionDisabled(attributes.autocorrectionDisabled)
    }
}
