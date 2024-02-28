//
//  TextEditorComponent.swift
//  Parra
//
//  Created by Mick MacCallum on 2/5/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

struct TextEditorComponent: TextEditorComponentType {
    // MARK: - Lifecycle

    init(
        config: TextEditorConfig,
        content: TextEditorContent,
        style: ParraAttributedTextEditorStyle
    ) {
        self.config = config
        self.content = content
        self.style = style
    }

    // MARK: - Internal

    var config: TextEditorConfig
    var content: TextEditorContent
    var style: ParraAttributedTextEditorStyle

    @EnvironmentObject var themeObserver: ParraThemeObserver

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // spacing controlled by individual component padding.
            titleLabel

            ZStack {
                applyStyle(
                    to: TextEditor(text: $text)
                )
                .onChange(of: text) { _, newValue in
                    hasReceivedInput = true

                    content.textChanged?(newValue)
                }

                UnevenRoundedRectangle(
                    cornerRadii: themeObserver.theme.cornerRadius
                        .value(for: style.attributes.cornerRadius)
                )
                .strokeBorder(
                    style.attributes.borderColor
                        ?? themeObserver.theme.palette.secondaryBackground,
                    lineWidth: style.attributes.borderWidth
                )

                placeholder

                characterCount
            }

            helperLabel
        }
        .padding(style.attributes.padding ?? .zero)
        .applyBackground(style.attributes.background)
    }

    static func applyStandardCustomizations(
        onto inputAttributes: TextEditorAttributes?,
        theme: ParraTheme,
        config: TextEditorConfig
    ) -> TextEditorAttributes {
        let palette = theme.palette

        let title = LabelAttributes.defaultFormTitle(
            in: theme,
            with: config.title
        )
        let helper = LabelAttributes.defaultFormHelper(
            in: theme,
            with: config.helper
        )

        return inputAttributes ?? TextEditorAttributes(
            title: title,
            helper: helper,
            cornerRadius: .medium,
            font: .body,
            fontColor: palette.primaryText.toParraColor(),
            padding: .zero,
            frame: FrameAttributes(
                minHeight: 60,
                idealHeight: 150,
                maxHeight: 240
            ),
            borderWidth: 1,
            borderColor: palette.secondaryText.toParraColor()
        )
    }

    @ViewBuilder
    func applyStyle(to view: some View) -> some View {
        view
            .tint(themeObserver.theme.palette.primary.toParraColor())
            .background(.clear)
            .contentMargins(
                .all,
                Constant.contentInsets,
                for: .automatic
            )
            .frame(
                minWidth: style.attributes.frame?.minWidth,
                idealWidth: style.attributes.frame?.idealWidth,
                maxWidth: style.attributes.frame?.maxWidth,
                minHeight: style.attributes.frame?.minHeight,
                idealHeight: style.attributes.frame?.idealHeight,
                maxHeight: style.attributes.frame?.maxHeight,
                alignment: style.attributes.frame?.alignment ?? .center
            )
            .foregroundStyle(fontColor)
            .font(style.attributes.font)
            .fontDesign(style.attributes.fontDesign)
            .fontWeight(style.attributes.fontWeight)
            .fontWidth(style.attributes.fontWidth)
            .lineLimit((config.minLines ?? 0)...)
    }

    // MARK: - Private

    private enum Constant {
        static let contentInsets = EdgeInsets(
            vertical: 4,
            horizontal: 8
        )

        static let primaryTextPadding = EdgeInsets(
            vertical: contentInsets.top + 8,
            horizontal: contentInsets.leading + 6
        )
    }

    @State private var text = ""
    @State private var hasReceivedInput = false

    @ViewBuilder private var titleLabel: some View {
        if let title = content.title, let titleStyle = style.titleStyle {
            LabelComponent(
                content: title,
                style: titleStyle
            )
        }
    }

    private var fontColor: Color {
        return style.attributes.fontColor
            ?? themeObserver.theme.palette.primaryText.toParraColor()
    }

    @ViewBuilder private var placeholder: some View {
        let attributes = style.attributes

        if let placeholder = content.placeholder, text.isEmpty {
            Text(placeholder.text)
                .frame(
                    maxWidth: .infinity,
                    maxHeight: .infinity,
                    alignment: .topLeading
                )
                .padding(Constant.primaryTextPadding)
                .foregroundStyle(fontColor.opacity(0.5))
                .font(attributes.font)
                .fontDesign(attributes.fontDesign)
                .fontWeight(attributes.fontWeight)
                .fontWidth(attributes.fontWidth)
                .allowsHitTesting(false)
        }
    }

    @ViewBuilder private var helperLabel: some View {
        let (message, baseStyle, isError): (
            String?,
            ParraAttributedLabelStyle?,
            Bool
        ) = if let errorMessage = style.content.errorMessage,
               config.showValidationErrors
        {
            // Even though we're displaying the error message, we only want to
            // render it as an error if input has already been received. This
            // prevents errors from being as apparent before the user has had
            // the chance to try to enter anything.
            (errorMessage, nil, hasReceivedInput)
        } else if let helperContent = content.helper,
                  let helperStyle = style.helperStyle
        {
            (helperContent.text, helperStyle, false)
        } else {
            (nil, nil, false)
        }

        if let message {
            let content = LabelContent(text: message)
            let style = baseStyle?.withContent(
                content: content
            ) ?? ParraAttributedLabelStyle(
                content: content,
                attributes: .defaultFormHelper(
                    in: themeObserver.theme,
                    with: LabelConfig(fontStyle: .caption),
                    erroring: isError
                ),
                theme: themeObserver.theme
            )

            LabelComponent(
                content: content,
                style: style
            )
            .padding(.trailing, 4)
        }
    }

    @ViewBuilder private var characterCount: some View {
        if config.showCharacterCountLabel {
            let (count, allowed) = characterCountString(
                with: config.maxCharacters
            )

            let content = LabelContent(text: count)

            VStack {
                LabelComponent(
                    content: content,
                    style: ParraAttributedLabelStyle(
                        content: content,
                        attributes: .defaultFormCallout(
                            in: themeObserver.theme,
                            with: LabelConfig(fontStyle: .callout),
                            erroring: !allowed
                        ),
                        theme: themeObserver.theme
                    )
                )
                .padding(
                    EdgeInsets(top: 0, leading: 0, bottom: 8, trailing: 10)
                )
            }
            .frame(
                maxWidth: .infinity,
                maxHeight: .infinity,
                alignment: .bottomTrailing
            )
        }
    }

    private func characterCountString(
        with max: Int?
    ) -> (String, Bool) {
        let characterCount = text.count

        guard let max else {
            return (String(characterCount), false)
        }

        return ("\(characterCount)/\(max)", characterCount <= max)
    }
}

@MainActor
private func renderTextEditor(
    config: TextEditorConfig,
    content: TextEditorContent,
    attributes: TextEditorAttributes? = nil,
    theme: ParraTheme = .default
) -> some View {
    let mergedAttributes = TextEditorComponent.applyStandardCustomizations(
        onto: attributes,
        theme: theme,
        config: config
    )

    return TextEditorComponent(
        config: config,
        content: content,
        style: ParraAttributedTextEditorStyle(
            config: config,
            content: content,
            attributes: mergedAttributes,
            theme: theme
        )
    )
    .environmentObject(
        ParraThemeObserver(
            theme: theme,
            notificationCenter: ParraNotificationCenter()
        )
    )
}

#Preview {
    VStack {
        renderTextEditor(
            config: FeedbackFormWidget.Config.default.textFields,
            content: TextEditorContent(
                title: "Some title",
                placeholder: "temp placeholder",
                helper: "helper text woo",
                errorMessage: nil,
                textChanged: nil
            )
        )

        renderTextEditor(
            config: FeedbackFormWidget.Config.default.textFields,
            content: TextEditorContent(
                title: "Some title",
                placeholder: "temp placeholder",
                helper: "helper text woo",
                errorMessage: nil,
                textChanged: nil
            )
        )

//        renderTextEditor(
//            config: FeedbackFormWidget.Config.default.textFields,
//            content: TextEditorContent(
//                title: "Some title",
//                placeholder: "temp placeholder",
//                helper: "helper text woo",
//                errorMessage: "That text isn't very good",
//                textChanged: nil
//            )
//        )
//
//        renderTextEditor(
//            config: FeedbackFormWidget.Config.default.textFields,
//            content: TextEditorContent(
//                title: "Some title",
//                placeholder: "temp placeholder",
//                helper: "helper text woo",
//                errorMessage: nil,
//                textChanged: nil
//            )
//        )
    }
    .padding()
}
