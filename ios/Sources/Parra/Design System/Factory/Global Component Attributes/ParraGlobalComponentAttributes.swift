//
//  ParraGlobalComponentAttributes.swift
//  Parra
//
//  Created by Mick MacCallum on 5/3/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Foundation
import SwiftUI

private let closeButtonSize: CGFloat = 18

open class ParraGlobalComponentAttributes: ComponentAttributesProvider {
    // MARK: - Lifecycle

    public required init() {}

    // MARK: - Open

    // MARK: Alerts

    open func inlineAlertAttributes(
        content: ParraAlertContent,
        level: ParraAlertLevel,
        localAttributes: ParraAttributes.InlineAlert?,
        theme: ParraTheme
    ) -> ParraAttributes.InlineAlert {
        let backgroundColor = defaultBackground(
            for: level,
            with: theme
        )

        let icon = defaultIcon(
            for: level,
            with: theme
        )

        let border = defaultBorder(
            for: level,
            with: theme
        )

        return ParraAttributes.InlineAlert(
            title: ParraAttributes.Label(
                text: ParraAttributes.Text(
                    style: .headline
                ),
                padding: .zero,
                frame: .flexible(
                    FlexibleFrameAttributes(
                        maxWidth: .infinity,
                        alignment: .leading
                    )
                )
            ),
            subtitle: ParraAttributes.Label(
                text: ParraAttributes.Text(
                    style: .subheadline
                ),
                frame: .flexible(
                    FlexibleFrameAttributes(
                        maxWidth: .infinity,
                        alignment: .leading
                    )
                )
            ),
            icon: icon,
            border: border,
            cornerRadius: .xl,
            padding: .xxl,
            background: backgroundColor
        ).mergingOverrides(localAttributes)
    }

    open func toastAlertAttributes(
        content: ParraAlertContent,
        level: ParraAlertLevel,
        localAttributes: ParraAttributes.ToastAlert?,
        theme: ParraTheme
    ) -> ParraAttributes.ToastAlert {
        let backgroundColor = defaultBackground(
            for: level,
            with: theme
        )

        let icon = defaultIcon(
            for: level,
            with: theme
        )

        let border = defaultBorder(
            for: level,
            with: theme
        )

        let edgePaddingSize: ParraPaddingSize = .xxl
        let edgePadding = theme.padding.value(
            for: edgePaddingSize
        )
        let labelTrailingPadding = edgePadding.trailing * 2.0 + closeButtonSize

        return ParraAttributes.ToastAlert(
            title: ParraAttributes.Label(
                text: ParraAttributes.Text(
                    style: .headline
                ),
                padding: .custom(
                    .padding(trailing: labelTrailingPadding)
                ),
                frame: .flexible(
                    FlexibleFrameAttributes(
                        maxWidth: .infinity,
                        alignment: .leading
                    )
                )
            ),
            subtitle: ParraAttributes.Label(
                text: ParraAttributes.Text(
                    style: .subheadline
                ),
                padding: .custom(
                    .padding(trailing: labelTrailingPadding)
                ),
                frame: .flexible(
                    FlexibleFrameAttributes(
                        maxWidth: .infinity,
                        alignment: .leading
                    )
                )
            ),
            icon: icon,
            dismissButton: defaultDismissButton(
                cornerPadding: edgePadding.trailing
            ),
            border: border,
            cornerRadius: .xl,
            padding: edgePaddingSize,
            background: backgroundColor
        ).mergingOverrides(localAttributes)
    }

    open func loadingIndicatorAlertAttributes(
        content: ParraLoadingIndicatorContent,
        localAttributes: ParraAttributes.LoadingIndicator?,
        theme: ParraTheme
    ) -> ParraAttributes.LoadingIndicator {
        let palette = theme.palette

        return ParraAttributes.LoadingIndicator(
            title: ParraAttributes.Label(
                text: ParraAttributes.Text(
                    style: .headline,
                    alignment: .center
                ),
                padding: .custom(
                    .padding(bottom: 2)
                )
            ),
            subtitle: ParraAttributes.Label(
                text: ParraAttributes.Text(
                    style: .subheadline,
                    alignment: .center
                )
            ),
            cancelButton: .init(
                normal: ParraAttributes.PlainButton.StatefulAttributes(
                    padding: .xs
                )
            ),
            border: ParraAttributes.Border(
                width: 0.0,
                color: nil
            ),
            cornerRadius: .xxl,
            padding: .xxl,
            background: palette.secondaryBackground.toParraColor()
        )
    }

    // MARK: Badges

    open func badgeAttributes(
        for size: ParraBadgeSize,
        variant: ParraBadgeVariant,
        swatch: ParraColorSwatch?,
        localAttributes: ParraAttributes.Badge?,
        theme: ParraTheme
    ) -> ParraAttributes.Badge {
        let palette = theme.palette
        let swatch = (swatch ?? palette.primary)

        let textColor: Color? = switch variant {
        case .outlined:
            nil
        case .contained:
            swatch.shade700
        }

        let text = ParraAttributes.Text(
            fontType: .size(
                size: size.fontSize,
                weight: size.fontWeight
            ),
            color: textColor,
            alignment: .center
        )

        switch variant {
        case .outlined:
            return ParraAttributes.Badge(
                text: text,
                icon: ParraAttributes.Image(
                    tint: swatch.shade600.toParraColor(),
                    size: CGSize(
                        width: size.padding.leading,
                        height: size.padding.leading
                    )
                ),
                border: ParraAttributes.Border(
                    width: 1,
                    color: palette.primarySeparator.toParraColor()
                ),
                cornerRadius: size.cornerRadius,
                padding: .custom(size.padding),
                background: palette.primaryBackground
            ).mergingOverrides(localAttributes)
        case .contained:
            return ParraAttributes.Badge(
                text: text,
                icon: ParraAttributes.Image(
                    tint: swatch.shade600.toParraColor(),
                    size: CGSize(
                        width: size.padding.leading,
                        height: size.padding.leading
                    )
                ),
                border: ParraAttributes.Border(
                    width: 1,
                    color: swatch.shade500.toParraColor()
                ),
                cornerRadius: size.cornerRadius,
                padding: .custom(size.padding),
                background: swatch.shade100.toParraColor()
            ).mergingOverrides(localAttributes)
        }
    }

    open func plainButtonAttributes(
        config: ParraTextButtonConfig,
        localAttributes: ParraAttributes.PlainButton?,
        theme: ParraTheme
    ) -> ParraAttributes.PlainButton {
        let size = config.size

        let cornerRadius = buttonCornerRadius(for: size)
        let padding = buttonPadding(
            for: size,
            theme: theme
        )

        return ParraAttributes.PlainButton(
            normal: ParraAttributes.PlainButton.StatefulAttributes(
                label: plainButtonLabelAttributes(
                    in: .normal,
                    config: config,
                    theme: theme
                ),
                cornerRadius: cornerRadius,
                padding: padding
            ),
            pressed: ParraAttributes.PlainButton.StatefulAttributes(
                label: plainButtonLabelAttributes(
                    in: .pressed,
                    config: config,
                    theme: theme
                ),
                cornerRadius: cornerRadius,
                padding: padding
            ),
            disabled: ParraAttributes.PlainButton.StatefulAttributes(
                label: plainButtonLabelAttributes(
                    in: .disabled,
                    config: config,
                    theme: theme
                ),
                cornerRadius: cornerRadius,
                padding: padding
            )
        ).mergingOverrides(localAttributes)
    }

    open func outlinedButtonAttributes(
        config: ParraTextButtonConfig,
        localAttributes: ParraAttributes.OutlinedButton?,
        theme: ParraTheme
    ) -> ParraAttributes.OutlinedButton {
        let size = config.size

        let cornerRadius = buttonCornerRadius(for: size)
        let padding = buttonPadding(
            for: size,
            theme: theme
        )
        let border = ParraAttributes.Border(
            width: 1,
            color: theme.palette.primary.toParraColor()
        )

        return ParraAttributes.OutlinedButton(
            normal: ParraAttributes.OutlinedButton.StatefulAttributes(
                label: outlinedButtonLabelAttributes(
                    in: .normal,
                    config: config,
                    theme: theme
                ),
                border: border,
                cornerRadius: cornerRadius,
                padding: padding
            ),
            pressed: ParraAttributes.OutlinedButton.StatefulAttributes(
                label: outlinedButtonLabelAttributes(
                    in: .pressed,
                    config: config,
                    theme: theme
                ),
                border: border,
                cornerRadius: cornerRadius,
                padding: padding
            ),
            disabled: ParraAttributes.OutlinedButton.StatefulAttributes(
                label: outlinedButtonLabelAttributes(
                    in: .disabled,
                    config: config,
                    theme: theme
                ),
                border: border,
                cornerRadius: cornerRadius,
                padding: padding
            )
        ).mergingOverrides(localAttributes)
    }

    open func containedButtonAttributes(
        config: ParraTextButtonConfig,
        localAttributes: ParraAttributes.ContainedButton?,
        theme: ParraTheme
    ) -> ParraAttributes.ContainedButton {
        let size = config.size

        let border = ParraAttributes.Border()
        let cornerRadius = buttonCornerRadius(for: size)
        let padding = buttonPadding(
            for: size,
            theme: theme
        )

        return ParraAttributes.ContainedButton(
            normal: ParraAttributes.ContainedButton.StatefulAttributes(
                label: containedButtonLabelAttributes(
                    in: .normal,
                    config: config,
                    theme: theme
                ),
                border: border,
                cornerRadius: cornerRadius,
                padding: padding
            ),
            pressed: ParraAttributes.ContainedButton.StatefulAttributes(
                label: containedButtonLabelAttributes(
                    in: .pressed,
                    config: config,
                    theme: theme
                ),
                border: border,
                cornerRadius: cornerRadius,
                padding: padding
            ),
            disabled: ParraAttributes.ContainedButton.StatefulAttributes(
                label: containedButtonLabelAttributes(
                    in: .disabled,
                    config: config,
                    theme: theme
                ),
                border: border,
                cornerRadius: cornerRadius,
                padding: padding
            )
        ).mergingOverrides(localAttributes)
    }

    // MARK: Empty States

    open func emptyStateAttributes(
        localAttributes: ParraAttributes.EmptyState?,
        theme: ParraTheme
    ) -> ParraAttributes.EmptyState {
        let palette = theme.palette

        return ParraAttributes.EmptyState(
            titleLabel: ParraAttributes.Label(
                text: ParraAttributes.Text(
                    style: .title
                ),
                padding: .custom(
                    .padding(top: 12)
                )
            ),
            subtitleLabel: ParraAttributes.Label(
                text: ParraAttributes.Text(
                    style: .subheadline,
                    alignment: .center
                ),
                padding: .custom(
                    .padding(top: 12)
                )
            ),
            icon: ParraAttributes.Image(
                tint: palette.secondary.shade400.toParraColor(),
                size: CGSize(width: 96, height: 96),
                padding: .custom(
                    .padding(bottom: 24)
                )
            ),
            primaryActionButton: ParraAttributes.ContainedButton(
                normal: ParraAttributes.ContainedButton.StatefulAttributes(
                    label: ParraAttributes.Label(
                        frame: .flexible(.init(maxWidth: 240))
                    ),
                    padding: .custom(
                        .padding(top: 36, bottom: 4)
                    )
                )
            ),
            secondaryActionButton: ParraAttributes.PlainButton(
                normal: ParraAttributes.PlainButton.StatefulAttributes(
                    label: ParraAttributes.Label(
                        frame: .flexible(.init(maxWidth: 240))
                    )
                )
            ),
            tint: palette.primary.toParraColor(),
            padding: .xxl,
            background: palette.primaryBackground
        )
    }

    // MARK: Images

    open func imageAttributes(
        content: ParraImageContent,
        localAttributes: ParraAttributes.Image?,
        theme: ParraTheme
    ) -> ParraAttributes.Image {
        return ParraAttributes.Image().mergingOverrides(localAttributes)
    }

    open func asyncImageAttributes(
        content: ParraAsyncImageContent,
        localAttributes: ParraAttributes.AsyncImage?,
        theme: ParraTheme
    ) -> ParraAttributes.AsyncImage {
        return ParraAttributes.AsyncImage().mergingOverrides(localAttributes)
    }

    // MARK: Image Buttons

    open func imageButtonAttributes(
        config: ParraImageButtonConfig,
        localAttributes: ParraAttributes.ImageButton?,
        theme: ParraTheme
    ) -> ParraAttributes.ImageButton {
        let size = config.size
        let type = config.type
        let variant = config.variant
        let palette = theme.palette

        let backgroundColor: Color? = switch variant {
        case .plain, .outlined:
            .clear
        case .contained:
            switch type {
            case .primary:
                palette.primary.toParraColor()
            case .secondary:
                palette.secondary.toParraColor()
            }
        }

        let tint: Color = switch variant {
        case .plain, .outlined:
            switch type {
            case .primary:
                palette.primary.toParraColor()
            case .secondary:
                palette.secondary.toParraColor()
            }
        case .contained:
            palette.primaryBackground.toParraColor()
        }

        let (borderColor, borderWidth): (Color?, CGFloat?) = switch variant {
        case .contained, .plain:
            (nil, nil)
        case .outlined:
            switch type {
            case .primary:
                (palette.primary.toParraColor(), 1.5)
            case .secondary:
                (palette.secondary.toParraColor(), 1.5)
            }
        }

        let frameSize = switch size {
        case .smallSquare:
            CGSize(width: 20, height: 20)
        case .mediumSquare:
            CGSize(width: 34, height: 34)
        case .largeSquare:
            CGSize(width: 50, height: 50)
        case .custom(let customSize):
            customSize
        }

        let padding = EdgeInsets(
            vertical: (frameSize.height * 0.2).rounded(.down),
            horizontal: (frameSize.width * 0.2).rounded(.down)
        )

        let cornerRadius: ParraCornerRadiusSize = switch size {
        case .smallSquare, .mediumSquare:
            .sm
        case .largeSquare:
            .md
        case .custom:
            .zero
        }

        let border = ParraAttributes.Border(
            width: borderWidth,
            color: borderColor
        )

        return ParraAttributes.ImageButton(
            normal: ParraAttributes.ImageButton.StatefulAttributes(
                image: ParraAttributes.Image(
                    tint: tint,
                    size: frameSize,
                    border: border,
                    cornerRadius: cornerRadius,
                    padding: .custom(padding),
                    background: backgroundColor
                ),
                border: ParraAttributes.Border(),
                cornerRadius: .zero,
                padding: .sm
            ),
            pressed: ParraAttributes.ImageButton.StatefulAttributes(
                image: ParraAttributes.Image(
                    tint: tint.opacity(0.8),
                    size: frameSize,
                    border: border,
                    cornerRadius: cornerRadius,
                    padding: .custom(padding),
                    background: backgroundColor
                ),
                border: ParraAttributes.Border(),
                cornerRadius: .zero,
                padding: .sm
            ),
            disabled: ParraAttributes.ImageButton.StatefulAttributes(
                image: ParraAttributes.Image(
                    tint: tint.opacity(0.6),
                    size: frameSize,
                    border: border,
                    cornerRadius: cornerRadius,
                    padding: .custom(padding),
                    background: backgroundColor
                ),
                border: ParraAttributes.Border(),
                cornerRadius: .zero,
                padding: .sm
            )
        ).mergingOverrides(localAttributes)
    }

    // MARK: Labels

    open func labelAttributes(
        localAttributes: ParraAttributes.Label? = nil,
        theme: ParraTheme
    ) -> ParraAttributes.Label {
        let fontType = localAttributes?.text.fontType ?? .style(style: .body)

        let text: ParraAttributes.Text = switch fontType {
        case .custom(let font):
            ParraAttributes.Text(
                font: font
            )
        case .size(
            let size,
            let width,
            let weight,
            let design
        ):
            ParraAttributes.Text(
                fontSize: size,
                width: width,
                weight: weight,
                design: design,
                color: theme.palette.primaryText.toParraColor()
            )
        case .style(
            let style,
            let width,
            let weight,
            let design
        ):
            textAttributes(
                for: style,
                theme: theme
            ).mergingOverrides(
                ParraAttributes.Text(
                    style: style,
                    width: width,
                    weight: weight,
                    design: design
                )
            )
        }

        return ParraAttributes.Label(
            text: text,
            icon: ParraAttributes.Image(
                tint: text.color
            )
        ).mergingOverrides(localAttributes)
    }

    // MARK: Menus

    open func menuAttributes(
        localAttributes: ParraAttributes.Menu?,
        theme: ParraTheme
    ) -> ParraAttributes.Menu {
        let palette = theme.palette

        let titleLabel = ParraAttributes.Label.defaultInputTitle(
            for: theme
        )

        let helperLabel = ParraAttributes.Label.defaultInputHelper(
            for: theme
        )

        var errorLabel = helperLabel
        errorLabel.text.color = palette.error.toParraColor()

        let unselectedMenuItemLabels = ParraAttributes.Label(
            text: ParraAttributes.Text(
                style: .body,
                weight: .regular,
                color: theme.palette.primaryText.toParraColor()
            ),
            padding: .xxl
        )

        var selectedMenuItems = unselectedMenuItemLabels
        selectedMenuItems.text = ParraAttributes.Text(
            style: .body,
            weight: .medium,
            color: theme.palette.primaryText.toParraColor()
        )

        return ParraAttributes.Menu(
            titleLabel: titleLabel,
            helperLabel: helperLabel,
            errorLabel: errorLabel,
            selectedMenuItemLabels: selectedMenuItems,
            unselectedMenuItemLabels: unselectedMenuItemLabels,
            tint: palette.secondaryText.toParraColor(),
            border: ParraAttributes.Border(
                width: 1,
                color: palette.secondarySeparator.toParraColor()
            ),
            cornerRadius: .md,
            padding: .md,
            background: palette.secondaryBackground
        ).mergingOverrides(localAttributes)
    }

    // MARK: Segments

    open func segmentedControlAttributes(
        localAttributes: ParraAttributes.Segment?,
        theme: ParraTheme
    ) -> ParraAttributes.Segment {
        return ParraAttributes.Segment(
            selectedOptionLabels: ParraAttributes.Label(
                text: ParraAttributes.Text(
                    style: .body,
                    color: theme.palette.primaryText.toParraColor()
                ),
                background: theme.palette.primary.toParraColor()
            ),
            unselectedOptionLabels: ParraAttributes.Label(
                text: ParraAttributes.Text(
                    style: .body,
                    color: theme.palette.secondaryText.toParraColor()
                ),
                background: theme.palette.secondaryBackground
            ),
            border: ParraAttributes.Border(
                width: 1.5,
                color: theme.palette.primarySeparator.toParraColor()
            ),
            cornerRadius: .md
        ).mergingOverrides(localAttributes)
    }

    // MARK: Text

    open func textAttributes(
        for textStyle: Font.TextStyle?,
        localAttributes: ParraAttributes.Text? = nil,
        theme: ParraTheme
    ) -> ParraAttributes.Text {
        if let overridenAttributes = theme.typography.getTextAttributes(
            for: textStyle
        ) {
            return overridenAttributes
        }

        let style = textStyle ?? .body

        let attributes = switch textStyle {
        case .body:
            ParraAttributes.Text(
                style: style,
                color: theme.palette.primaryText.toParraColor()
            )
        case .subheadline:
            ParraAttributes.Text(
                style: style,
                color: theme.palette.primaryText.toParraColor()
            )
        case .largeTitle, .title, .title2, .title3:
            ParraAttributes.Text(
                style: style,
                weight: .bold,
                color: theme.palette.primaryText.toParraColor(),
                alignment: .leading
            )
        case .callout:
            ParraAttributes.Text(
                style: style,
                weight: .medium,
                color: theme.palette.secondaryText.toParraColor().opacity(0.8)
            )
        default:
            ParraAttributes.Text(
                style: style
            )
        }

        return attributes.mergingOverrides(localAttributes)
    }

    // MARK: Text Editors

    open func textEditorAttributes(
        config: ParraTextEditorConfig,
        localAttributes: ParraAttributes.TextEditor?,
        theme: ParraTheme
    ) -> ParraAttributes.TextEditor {
        let palette = theme.palette

        let text = ParraAttributes.Text(
            style: .body,
            color: palette.primaryText.toParraColor(),
            alignment: .leading
        )

        var placeholderText = text
        placeholderText.color = Color(UIColor.placeholderText)

        let titleLabel = ParraAttributes.Label.defaultInputTitle(
            for: theme
        )

        let helperLabel = ParraAttributes.Label.defaultInputHelper(
            for: theme
        )

        var errorLabel = helperLabel
        errorLabel.text.color = palette.error.toParraColor()

        let characterCountLabel = ParraAttributes.Label(
            text: ParraAttributes.Text(
                style: .caption,
                color: palette.secondaryText.toParraColor().opacity(0.8),
                alignment: .trailing
            ),
            padding: .custom(
                .padding(bottom: 8, trailing: 10)
            )
        )

        return ParraAttributes.TextEditor(
            text: text,
            placeholderText: placeholderText,
            titleLabel: titleLabel,
            helperLabel: helperLabel,
            errorLabel: errorLabel,
            characterCountLabel: characterCountLabel,
            border: ParraAttributes.Border(
                width: 1,
                color: palette.secondarySeparator.toParraColor()
            ),
            cornerRadius: .lg,
            padding: .md,
            background: palette.secondaryBackground,
            tint: palette.primary.toParraColor(),
            keyboardType: config.keyboardType,
            textCase: config.textCase,
            textContentType: config.textContentType,
            textInputAutocapitalization: config.textInputAutocapitalization,
            autocorrectionDisabled: config.autocorrectionDisabled,
            frame: .flexible(
                FlexibleFrameAttributes(
                    minHeight: 60,
                    idealHeight: 150,
                    maxHeight: 240
                )
            )
        ).mergingOverrides(localAttributes)
    }

    // MARK: Text Fields

    open func textInputAttributes(
        config: ParraTextInputConfig,
        localAttributes: ParraAttributes.TextInput? = nil,
        theme: ParraTheme
    ) -> ParraAttributes.TextInput {
        let palette = theme.palette

        let text = ParraAttributes.Text(
            style: .body,
            color: palette.primaryText.toParraColor()
        )

        let titleLabel = ParraAttributes.Label.defaultInputTitle(
            for: theme
        )

        let helperLabel = ParraAttributes.Label.defaultInputHelper(
            for: theme
        )

        var errorLabel = helperLabel
        errorLabel.text.color = palette.error.toParraColor()

        return ParraAttributes.TextInput(
            text: text,
            titleLabel: titleLabel,
            helperLabel: helperLabel,
            errorLabel: errorLabel,
            border: ParraAttributes.Border(
                width: 1,
                color: palette.secondarySeparator.toParraColor()
            ),
            cornerRadius: .lg,
            padding: .md,
            background: palette.secondaryBackground,
            tint: palette.primary.toParraColor(),
            keyboardType: config.keyboardType,
            textCase: config.textCase,
            textContentType: config.textContentType,
            textInputAutocapitalization: config.textInputAutocapitalization,
            autocorrectionDisabled: config.autocorrectionDisabled,
            frame: .fixed(FixedFrameAttributes(height: 52))
        ).mergingOverrides(localAttributes)
    }

    // MARK: - Public

    public static let `default` = ParraGlobalComponentAttributes()

    // MARK: - Internal

    // MARK: Buttons

    func buttonPadding(
        for size: ParraButtonSize,
        theme: ParraTheme
    ) -> ParraPaddingSize {
        let horizontalPadding = theme.padding.value(
            for: .md
        )

        let verticalPaddingSize: ParraPaddingSize = switch size {
        case .small, .medium:
            .sm
        case .large:
            .md
        }

        let verticalPadding = theme.padding.value(
            for: verticalPaddingSize
        )

        return .custom(
            .padding(
                top: verticalPadding.top,
                leading: horizontalPadding.leading,
                bottom: verticalPadding.bottom,
                trailing: horizontalPadding.trailing
            )
        )
    }

    @inlinable
    func buttonCornerRadius(
        for size: ParraButtonSize
    ) -> ParraCornerRadiusSize {
        switch size {
        case .small:
            return .sm
        case .medium:
            return .md
        case .large:
            return .lg
        }
    }

    // MARK: - Plain Button

    func plainButtonTextColor(
        in state: ParraButtonState,
        with type: ParraButtonType,
        theme: ParraTheme
    ) -> ParraColor {
        let baseColor: Color = switch type {
        case .primary:
            theme.palette.primary.toParraColor()
        case .secondary:
            theme.palette.secondary.toParraColor()
        }

        return switch state {
        case .normal:
            baseColor
        case .disabled:
            baseColor.opacity(0.6)
        case .pressed:
            baseColor.opacity(0.6)
        }
    }

    func plainButtonTextAttributes(
        in state: ParraButtonState,
        config: ParraTextButtonConfig,
        theme: ParraTheme
    ) -> ParraAttributes.Text {
        var textAttributes = baseTextAttributes(
            for: config.size,
            theme: theme
        )

        textAttributes.color = plainButtonTextColor(
            in: state,
            with: config.type,
            theme: theme
        )

        return textAttributes
    }

    func plainButtonLabelAttributes(
        in state: ParraButtonState,
        config: ParraTextButtonConfig,
        theme: ParraTheme
    ) -> ParraAttributes.Label {
        let text = plainButtonTextAttributes(
            in: state,
            config: config,
            theme: theme
        )

        return ParraAttributes.Label(
            text: text,
            icon: ParraAttributes.Image(
                tint: text.color
            ),
            padding: baseTitlePadding(for: config.size),
            background: nil,
            frame: baseLabelFrameAttributes(
                isMaxWidth: config.isMaxWidth
            )
        )
    }

    // MARK: - Outlined Button

    func outlinedButtonBackground(
        in state: ParraButtonState,
        with type: ParraButtonType,
        theme: ParraTheme
    ) -> Color? {
        return theme.palette.primaryBackground
    }

    func outlinedButtonTextColor(
        in state: ParraButtonState,
        with type: ParraButtonType,
        theme: ParraTheme
    ) -> Color? {
        let baseColor: Color = switch type {
        case .primary:
            theme.palette.primary.toParraColor()
        case .secondary:
            theme.palette.secondary.toParraColor()
        }

        return switch state {
        case .normal:
            baseColor
        case .disabled:
            baseColor.opacity(0.6)
        case .pressed:
            baseColor.opacity(0.6)
        }
    }

    func outlinedButtonTextAttributes(
        in state: ParraButtonState,
        config: ParraTextButtonConfig,
        theme: ParraTheme
    ) -> ParraAttributes.Text {
        var textAttributes = baseTextAttributes(
            for: config.size,
            theme: theme
        )

        textAttributes.color = outlinedButtonTextColor(
            in: state,
            with: config.type,
            theme: theme
        )

        return textAttributes
    }

    func outlinedButtonLabelAttributes(
        in state: ParraButtonState,
        config: ParraTextButtonConfig,
        theme: ParraTheme
    ) -> ParraAttributes.Label {
        let text = outlinedButtonTextAttributes(
            in: state,
            config: config,
            theme: theme
        )

        return ParraAttributes.Label(
            text: text,
            icon: ParraAttributes.Image(
                tint: text.color
            ),
            padding: baseTitlePadding(for: config.size),
            background: outlinedButtonBackground(
                in: state,
                with: config.type,
                theme: theme
            ),
            frame: baseLabelFrameAttributes(
                isMaxWidth: config.isMaxWidth
            )
        )
    }

    // MARK: - Contained Button

    func containedButtonTextColor(
        in state: ParraButtonState,
        with type: ParraButtonType,
        theme: ParraTheme
    ) -> Color? {
        let baseColor = ParraColorSwatch.neutral.shade50

        return switch state {
        case .normal:
            baseColor
        case .disabled:
            baseColor.opacity(0.6)
        case .pressed:
            baseColor.opacity(0.8)
        }
    }

    func containedButtonTextAttributes(
        in state: ParraButtonState,
        config: ParraTextButtonConfig,
        theme: ParraTheme
    ) -> ParraAttributes.Text {
        var textAttributes = baseTextAttributes(
            for: config.size,
            theme: theme
        )

        textAttributes.color = containedButtonTextColor(
            in: state,
            with: config.type,
            theme: theme
        )

        return textAttributes
    }

    func containedButtonBackground(
        in state: ParraButtonState,
        with type: ParraButtonType,
        theme: ParraTheme
    ) -> Color? {
        let baseBackground: Color = switch type {
        case .primary:
            theme.palette.primary.toParraColor()
        case .secondary:
            theme.palette.secondary.toParraColor()
        }

        return switch state {
        case .normal:
            baseBackground
        case .disabled:
            baseBackground.opacity(0.6)
        case .pressed:
            baseBackground.opacity(0.8)
        }
    }

    func containedButtonLabelAttributes(
        in state: ParraButtonState,
        config: ParraTextButtonConfig,
        theme: ParraTheme
    ) -> ParraAttributes.Label {
        let text = containedButtonTextAttributes(
            in: state,
            config: config,
            theme: theme
        )

        let label = ParraAttributes.Label(
            text: text,
            icon: ParraAttributes.Image(
                tint: text.color
            ),
            padding: baseTitlePadding(for: config.size),
            background: containedButtonBackground(
                in: state,
                with: config.type,
                theme: theme
            ),
            frame: baseLabelFrameAttributes(
                isMaxWidth: config.isMaxWidth
            )
        )

        return label
    }

    // MARK: - Private

    private func defaultDismissButton(
        cornerPadding: CGFloat
    ) -> ParraAttributes.ImageButton {
        return ParraAttributes.ImageButton(
            normal: ParraAttributes.ImageButton.StatefulAttributes(
                image: ParraAttributes.Image(
                    tint: Color(
                        lightVariant: ParraColorSwatch.gray.shade600,
                        darkVariant: ParraColorSwatch.gray.shade300
                    ),
                    size: CGSize(
                        width: closeButtonSize,
                        height: closeButtonSize
                    ),
                    padding: .custom(
                        .padding(
                            trailing: cornerPadding
                        )
                    )
                ),
                border: ParraAttributes.Border(),
                cornerRadius: .zero,
                padding: .zero
            ),
            pressed: ParraAttributes.ImageButton.StatefulAttributes(
                image: ParraAttributes.Image(
                    tint: Color(
                        lightVariant: ParraColorSwatch.gray.shade600,
                        darkVariant: ParraColorSwatch.gray.shade300
                    ).opacity(0.8),
                    size: CGSize(
                        width: closeButtonSize,
                        height: closeButtonSize
                    ),
                    padding: .custom(
                        .padding(
                            trailing: cornerPadding
                        )
                    )
                ),
                border: ParraAttributes.Border(),
                cornerRadius: .zero,
                padding: .zero
            ),
            disabled: ParraAttributes.ImageButton.StatefulAttributes(
                image: ParraAttributes.Image(
                    tint: Color(
                        lightVariant: ParraColorSwatch.gray.shade600,
                        darkVariant: ParraColorSwatch.gray.shade300
                    ).opacity(0.6),
                    size: CGSize(
                        width: closeButtonSize,
                        height: closeButtonSize
                    ),
                    padding: .custom(
                        .padding(
                            trailing: cornerPadding
                        )
                    )
                ),
                border: ParraAttributes.Border(),
                cornerRadius: .zero,
                padding: .zero
            )
        )
    }

    private func defaultBackground(
        for level: ParraAlertLevel,
        with theme: ParraTheme
    ) -> ParraColor {
        return theme.palette.secondaryBackground
    }

    private func defaultIcon(
        for level: ParraAlertLevel,
        with theme: ParraTheme
    ) -> ParraAttributes.Image {
        let iconTintColor = defaultIconTint(
            for: level,
            with: theme
        )

        return ParraAttributes.Image(
            tint: iconTintColor,
            size: CGSize(width: 24, height: 24)
        )
    }

    private func defaultIconTint(
        for level: ParraAlertLevel,
        with theme: ParraTheme
    ) -> ParraColor {
        let palette = theme.palette

        return switch level {
        case .success:
            palette.success.toParraColor().opacity(0.9)
        case .info:
            palette.primary.toParraColor().opacity(0.9)
        case .warn:
            palette.warning.toParraColor().opacity(0.9)
        case .error:
            palette.error.toParraColor().opacity(0.9)
        }
    }

    private func defaultBorder(
        for level: ParraAlertLevel,
        with theme: ParraTheme
    ) -> ParraAttributes.Border {
        let palette = theme.palette

        let color = switch level {
        case .success:
            palette.success.toParraColor()
        case .info:
            palette.primary.toParraColor()
        case .warn:
            palette.warning.toParraColor()
        case .error:
            palette.error.toParraColor()
        }

        return ParraAttributes.Border(
            width: 1.25,
            color: color
        )
    }

    private func baseLabelFrameAttributes(
        isMaxWidth: Bool
    ) -> FrameAttributes {
        return .flexible(
            FlexibleFrameAttributes(
                maxWidth: isMaxWidth ? .infinity : nil
            )
        )
    }

    private func baseTextAttributes(
        for size: ParraButtonSize,
        theme: ParraTheme
    ) -> ParraAttributes.Text {
        return theme.typography.getTextAttributes(
            for: baseTextStyle(for: size)
        ) ?? ParraAttributes.Text(
            font: baseFont(for: size),
            alignment: .center
        )
    }

    private func baseTextStyle(
        for size: ParraButtonSize
    ) -> Font.TextStyle {
        switch size {
        case .small:
            return .footnote
        case .medium:
            return .subheadline
        case .large:
            return .headline
        }
    }

    private func baseFontSize(
        for size: ParraButtonSize
    ) -> CGFloat {
        return switch size {
        case .small:
            14.0
        case .medium:
            16.0
        case .large:
            18.0
        }
    }

    private func baseLineHeight(
        for size: ParraButtonSize
    ) -> CGFloat {
        return switch size {
        case .small:
            20.0
        case .medium:
            24.0
        case .large:
            28.0
        }
    }

    private func baseFont(
        for size: ParraButtonSize
    ) -> Font {
        return Font.system(
            size: baseFontSize(for: size),
            weight: .semibold
        )
    }

    private func baseTitlePadding(
        for size: ParraButtonSize
    ) -> ParraPaddingSize {
        let lineHeight = baseLineHeight(for: size)
        let fontSize = baseFontSize(for: size)

        let extraVerticalPadding = ((lineHeight - fontSize) / 2.0).rounded()
        let titlePadding = switch size {
        case .small:
            EdgeInsets(
                vertical: 4 + extraVerticalPadding,
                horizontal: 8
            )
        case .medium:
            EdgeInsets(
                vertical: 6 + extraVerticalPadding,
                horizontal: 10
            )
        case .large:
            EdgeInsets(
                vertical: 10 + extraVerticalPadding,
                horizontal: 12
            )
        }

        return ParraPaddingSize.custom(titlePadding)
    }
}
