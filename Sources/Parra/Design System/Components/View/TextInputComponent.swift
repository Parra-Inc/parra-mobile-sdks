//
//  TextInputComponent.swift
//  Parra
//
//  Created by Mick MacCallum on 2/19/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

struct TextInputComponent: TextInputComponentType {
    // MARK: - Lifecycle

    init(
        config: TextInputConfig,
        content: TextInputContent,
        style: ParraAttributedTextInputStyle
    ) {
        self.config = config
        self.content = content
        self.style = style
    }

    // MARK: - Internal

    var config: TextInputConfig
    var content: TextInputContent
    var style: ParraAttributedTextInputStyle

    @EnvironmentObject var themeObserver: ParraThemeObserver

    @ViewBuilder var baseView: some View {
        let prompt = Text(content.placeholder?.text ?? "")

        if config.isSecure {
            SecureField(
                text: $text,
                prompt: prompt
            ) {
                EmptyView()
            }
        } else {
            TextField(
                text: $text,
                prompt: prompt
            ) {
                EmptyView()
            }
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // spacing controlled by individual component padding.
            titleLabel

            baseView
                .textInputAutocapitalization(.never)
                .disableAutocorrection(true)
                .textFieldStyle(style)
                .onChange(of: text) { _, newValue in
                    hasReceivedInput = true

                    content.textChanged?(newValue)
                }

            helperLabel
        }
        .padding(style.attributes.padding ?? .zero)
        .applyBackground(style.attributes.background)
    }

    // MARK: - Private

    @State private var text = ""
    @State private var hasReceivedInput = false

    @ViewBuilder private var titleLabel: some View {
        if let title = content.title, let titleStyle = style.titleStyle {
            EmptyView()
//            LabelComponent(
//                content: title,
//                style: titleStyle
//            )
        }
    }

    @ViewBuilder private var helperLabel: some View {
        EmptyView()
//        let (message, baseStyle, isError): (
//            String?,
//            ParraAttributedLabelStyle?,
//            Bool
//        ) = if let errorMessage = style.content.errorMessage,
//               config.preferValidationErrorsToHelperMessage
//        {
//            // Even though we're displaying the error message, we only want to
//            // render it as an error if input has already been received. This
//            // prevents errors from being as apparent before the user has had
//            // the chance to try to enter anything.
//            (errorMessage, nil, hasReceivedInput)
//        } else if let helperContent = content.helper,
//                  let helperStyle = style.helperStyle
//        {
//            (helperContent.text, helperStyle, false)
//        } else {
//            (nil, nil, false)
//        }
//
//        let content = if let message {
//            LabelContent(text: message)
//        } else {
//            LabelContent(text: "")
//        }
//
//        let style = baseStyle?.withContent(
//            content: content
//        ) ?? ParraAttributedLabelStyle(
//            content: content,
//            attributes: .defaultFormHelper(
//                in: themeObserver.theme,
//                with: LabelConfig(fontStyle: .caption),
//                erroring: isError
//            ),
//            theme: themeObserver.theme
//        )
//
//        LabelComponent(
//            content: content,
//            style: style
//        )
//        .lineLimit(1)
    }
}

// #Preview {
//    ParraViewPreview { factory in
//        VStack {
//            factory.buildTextInput(
//                config: FeedbackFormWidget.Config.default.inputFields,
//                content: TextInputContent(
//                    title: "Some title",
//                    placeholder: "temp placeholder",
//                    helper: "helper text woo",
//                    errorMessage: nil,
//                    textChanged: nil
//                )
//            )
//
//            factory.buildTextInput(
//                config: FeedbackFormWidget.Config.default.inputFields,
//                content: TextInputContent(
//                    title: "Some title",
//                    placeholder: "temp placeholder",
//                    helper: "helper text woo",
//                    errorMessage: nil,
//                    textChanged: nil
//                )
//            )
//
//            factory.buildTextInput(
//                config: FeedbackFormWidget.Config.default.inputFields,
//                content: TextInputContent(
//                    title: "Some title",
//                    placeholder: "",
//                    helper: "helper text woo",
//                    errorMessage: "That text isn't very good",
//                    textChanged: nil
//                )
//            )
//
//            factory.buildTextInput(
//                config: FeedbackFormWidget.Config.default.inputFields,
//                content: TextInputContent(
//                    title: "Some title",
//                    placeholder: nil,
//                    helper: "helper text woo",
//                    errorMessage: nil,
//                    textChanged: nil
//                )
//            )
//
//            factory.buildTextInput(
//                config: TextInputConfig(
//                    validationRules: [.hasLowercase, .hasUppercase],
//                    isSecure: true
//                ),
//                content: TextInputContent(
//                    title: "Some title",
//                    placeholder: nil,
//                    helper: "helper text woo",
//                    errorMessage: nil,
//                    textChanged: nil
//                )
//            )
//        }
//    }
//    .padding()
// }
