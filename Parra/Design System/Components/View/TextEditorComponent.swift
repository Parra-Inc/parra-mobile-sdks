//
//  TextEditorComponent.swift
//  Parra
//
//  Created by Mick MacCallum on 2/5/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

struct TextEditorComponent: TextEditorComponentType {
    // MARK: Lifecycle

    init(
        config: TextEditorConfig,
        content: TextEditorContent,
        style: ParraAttributedTextEditorStyle
    ) {
        self.config = config
        self.content = content
        self.style = style
    }

    // MARK: Internal

    var config: TextEditorConfig
    var content: TextEditorContent
    var style: ParraAttributedTextEditorStyle

    @EnvironmentObject var themeObserver: ParraThemeObserver

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // spacing controlled by individual component padding.
            if let title = content.title, let titleStyle = style.titleStyle {
                LabelComponent(
                    config: config.title,
                    content: title,
                    style: titleStyle
                )
            }

            applyStyle(
                to: TextEditor(text: $text)
            )
            .onChange(of: text) { _, newValue in
                hasReceivedInput = true

                content.textChanged?(newValue)
            }

            inputMessage
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
                idealHeight: 100,
                maxHeight: 200
            ),
            borderWidth: 1,
            borderColor: palette.secondaryText.toParraColor()
        )
    }

    @ViewBuilder
    func applyStyle(to view: some View) -> some View {
        let theme = themeObserver.theme
        let palette = themeObserver.theme.palette

        let attributes = style.attributes
        let fontColor = attributes.fontColor ?? palette.primaryText
            .toParraColor()

        let contentInsets = EdgeInsets(vertical: 4, horizontal: 8)

        view
            .tint(theme.palette.primary.toParraColor())
            .background(.clear)
            .contentMargins(
                .all,
                contentInsets,
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
            .overlay(
                UnevenRoundedRectangle(
                    cornerRadii: theme.cornerRadius
                        .value(for: attributes.cornerRadius)
                )
                .stroke(
                    attributes.borderColor ?? palette.secondaryBackground,
                    lineWidth: attributes.borderWidth
                )
            )
            .overlay(alignment: .topLeading) {
                if let placeholder = content.placeholder, text.isEmpty {
                    Text(placeholder.text)
                        .frame(
                            maxWidth: .infinity,
                            maxHeight: .infinity,
                            alignment: .topLeading
                        )
                        .padding(EdgeInsets(
                            vertical: contentInsets.top + 8,
                            horizontal: contentInsets.leading + 6
                        ))
                        .foregroundStyle(fontColor.opacity(0.5))
                        .font(attributes.font)
                        .fontDesign(attributes.fontDesign)
                        .fontWeight(attributes.fontWeight)
                        .fontWidth(attributes.fontWidth)
                        .allowsHitTesting(false)

                } else {
                    EmptyView()
                }
            }
            .font(attributes.font)
            .fontDesign(attributes.fontDesign)
            .fontWeight(attributes.fontWeight)
            .fontWidth(attributes.fontWidth)
            .lineLimit((config.minLines ?? 0)...)
    }

    // MARK: Private

    @State private var text = ""
    @State private var hasReceivedInput = false

    @ViewBuilder private var inputMessage: some View {
//        if let helper = content.helper, let helperStyle = style.helperStyle {
//            LabelComponent(
//                config: config.helper,
//                content: helper,
//                style: helperStyle
//            )
//            .frame(maxWidth: .infinity, alignment: .trailing)
//        }
        EmptyView()
//        let (message, isError): (String?, Bool) = if let errorMessage = content.errorMessage {
//            (errorMessage, true)
//        } else if config.showStatusLabel {
//            characterCountString(with: config.maxCharacters)
//        } else {
//            (nil, false)
//        }
//
//        if let message {
//            Text(message)
//                .foregroundColor(
//                    isError && hasReceivedInput
//                        ? themeObserver.theme.palette.error.toParraColor()
//                        : themeObserver.theme.palette.secondaryText.toParraColor()
//                )
//                .padding(.trailing, 4)
//        } else {
//            EmptyView()
//        }
    }

    private func characterCountString(with max: Int?) -> (String, Bool) {
        let characterCount = text.count

        guard let max else {
            return (String(characterCount), false)
        }

        return ("\(characterCount)/\(max)", characterCount > max)
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
            config: FeedbackFormConfig.default.textFields,
            content: TextEditorContent(
                title: "Some title",
                placeholder: "temp placeholder",
                helper: "helper text woo",
                errorMessage: nil,
                textChanged: nil
            )
        )

        renderTextEditor(
            config: FeedbackFormConfig.default.textFields,
            content: TextEditorContent(
                title: "Some title",
                placeholder: "temp placeholder",
                helper: "helper text woo",
                errorMessage: nil,
                textChanged: nil
            )
        )

        renderTextEditor(
            config: FeedbackFormConfig.default.textFields,
            content: TextEditorContent(
                title: "Some title",
                placeholder: "temp placeholder",
                helper: "helper text woo",
                errorMessage: nil,
                textChanged: nil
            )
        )

        renderTextEditor(
            config: FeedbackFormConfig.default.textFields,
            content: TextEditorContent(
                title: "Some title",
                placeholder: "temp placeholder",
                helper: "helper text woo",
                errorMessage: nil,
                textChanged: nil
            )
        )
    }
    .padding()
}
