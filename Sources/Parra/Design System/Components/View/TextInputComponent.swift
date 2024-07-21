//
//  TextInputComponent.swift
//  Parra
//
//  Created by Mick MacCallum on 2/19/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

struct TextInputComponent: View {
    // MARK: - Lifecycle

    init(
        config: TextInputConfig,
        content: TextInputContent,
        attributes: ParraAttributes.TextInput
    ) {
        self.config = config
        self.content = content
        self.attributes = attributes
        self._text = State(initialValue: content.defaultText)
    }

    // MARK: - Internal

    var config: TextInputConfig
    var content: TextInputContent
    var attributes: ParraAttributes.TextInput

    @EnvironmentObject var componentFactory: ComponentFactory

    @ViewBuilder var baseView: some View {
        let prompt = Text(content.placeholder?.text ?? "")

        if config.isSecure {
            // When Apple is suggesting a strong password, they highlight the
            // field yellow. In dark mode this means that the font color doesn't
            // have enough contrast to actually be visible. Using a grey in this
            // situation is a compromise to be visible with and without the
            // yellow banner. This isn't an issue in light mode since the font
            // color contrasts both with white and yellow backgrounds.
            let textColorOverride = colorScheme == .dark
                ? ParraColorSwatch.gray.shade400 : attributes.text.color

            SecureField(
                text: $text,
                prompt: prompt
            ) {
                EmptyView()
            }
            .foregroundStyle(
                textColorOverride ?? themeManager.theme.palette.primaryText
                    .toParraColor()
            )
            .onAppear {
                if let passwordRuleDescriptor = config.passwordRuleDescriptor,
                   config.isSecure
                {
                    UITextField.appearance()
                        .passwordRules = UITextInputPasswordRules(
                            descriptor: passwordRuleDescriptor
                        )
                }
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
                .overlay {
                    if !text.isEmpty, isFocused {
                        HStack {
                            Spacer()

                            Button {
                                text = ""
                            } label: {
                                Image(systemName: "multiply.circle.fill")
                            }
                            .foregroundColor(.secondary.opacity(0.8))
                            .padding(.trailing, 3)
                        }
                    }
                }
                .applyTextInputAttributes(
                    attributes,
                    using: themeManager.theme
                )
                .focused($isFocused)
                .onChange(of: text) { _, newValue in
                    hasReceivedInput = true

                    content.textChanged?(newValue)
                }

            helperLabel
        }
        .applyPadding(
            size: attributes.padding,
            on: [.horizontal, .bottom],
            from: themeManager.theme
        )
        .onTapGesture {
            isFocused = true
        }
    }

    // MARK: - Private

    @FocusState private var isFocused: Bool

    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject private var themeManager: ParraThemeManager

    @State private var text: String
    @State private var hasReceivedInput = false

    @ViewBuilder private var titleLabel: some View {
        withContent(
            content: content.title
        ) { content in
            componentFactory.buildLabel(
                content: content,
                localAttributes: attributes.titleLabel
            )
        }
    }

    @ViewBuilder private var helperLabel: some View {
        let (message, isError): (
            String?,
            Bool
        ) = if let errorMessage = content.errorMessage,
               config.preferValidationErrorsToHelperMessage
        {
            // Even though we're displaying the error message, we only want to
            // render it as an error if input has already been received. This
            // prevents errors from being as apparent before the user has had
            // the chance to try to enter anything.
            (errorMessage, hasReceivedInput)
        } else if let helperContent = content.helper {
            (helperContent.text, false)
        } else {
            (nil, false)
        }

        let content = if let message {
            LabelContent(text: message)
        } else {
            LabelContent(text: "")
        }

        if content.text.isEmpty, config.resizeWhenHelperMessageIsVisible {
            EmptyView()
        } else {
            let helperAttributes = isError
                ? attributes.errorLabel : attributes.helperLabel

            componentFactory.buildLabel(
                content: content,
                localAttributes: helperAttributes
            )
            .lineLimit(1)
        }
    }
}

#Preview {
    ParraViewPreview { factory in
        VStack {
            factory.buildTextInput(
                config: TextInputConfig(),
                content: TextInputContent(
                    title: "Some title",
                    placeholder: "temp placeholder",
                    helper: "helper text woo",
                    errorMessage: nil,
                    textChanged: nil
                )
            )

            factory.buildTextInput(
                config: TextInputConfig(),
                content: TextInputContent(
                    title: "Some title",
                    placeholder: "temp placeholder",
                    helper: "helper text woo",
                    errorMessage: nil,
                    textChanged: nil
                )
            )

            factory.buildTextInput(
                config: TextInputConfig(),
                content: TextInputContent(
                    title: "Some title",
                    placeholder: "",
                    helper: "helper text woo",
                    errorMessage: "That text isn't very good",
                    textChanged: nil
                )
            )

            factory.buildTextInput(
                config: TextInputConfig(),
                content: TextInputContent(
                    title: "Some title",
                    placeholder: nil,
                    helper: "helper text woo",
                    errorMessage: nil,
                    textChanged: nil
                )
            )

            factory.buildTextInput(
                config: TextInputConfig(
                    validationRules: [.hasLowercase, .hasUppercase],
                    isSecure: true
                ),
                content: TextInputContent(
                    title: "Some title",
                    placeholder: nil,
                    helper: "helper text woo",
                    errorMessage: nil,
                    textChanged: nil
                )
            )
        }
    }
    .padding()
}
