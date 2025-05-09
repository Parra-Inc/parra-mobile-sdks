//
//  ParraTextInputComponent.swift
//  Parra
//
//  Created by Mick MacCallum on 2/19/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

public struct ParraTextInputComponent: View {
    // MARK: - Lifecycle

    init(
        config: ParraTextInputConfig,
        content: ParraTextInputContent,
        attributes: ParraAttributes.TextInput
    ) {
        self.config = config
        self.content = content
        self.attributes = attributes
        self._text = State(initialValue: content.defaultText)
    }

    // MARK: - Public

    public internal(set) var config: ParraTextInputConfig
    public internal(set) var content: ParraTextInputContent
    public internal(set) var attributes: ParraAttributes.TextInput

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // spacing controlled by individual component padding.
            titleLabel

            baseView
                .applyTextInputAttributes(
                    attributes,
                    using: parraTheme
                )
                .onChange(of: text) { _, newValue in
                    hasReceivedInput = true

                    content.textChanged?(newValue)
                }

            helperLabel
        }
        .applyPadding(
            size: attributes.padding,
            on: [.horizontal, .bottom],
            from: parraTheme
        )
        .onAppear {
            if config.shouldAutoFocus {
                focusState = config.isSecure ? .secure : .normal
            } else {
                focusState = nil
            }
        }
        .onTapGesture {
            if let lastFocusState {
                focusState = lastFocusState
            }
        }
        .onChange(of: focusState, initial: true) { _, newValue in
            lastFocusState = newValue
        }
    }

    // MARK: - Internal

    enum SecureFocusState {
        case normal
        case visible
    }

    enum FocusField {
        case normal
        case secure
        case secureRevealed
    }

    @ViewBuilder var baseView: some View {
        let prompt = Text(content.placeholder?.text ?? "")

        if config.isSecure {
            if secureInputRevealingPassword {
                TextField(
                    text: $text,
                    prompt: prompt
                ) {
                    EmptyView()
                }
                .focusablePadding(.trailing, text.isEmpty ? 0 : 30)
                .focused($focusState, equals: .secureRevealed)
                .overlay {
                    if !text.isEmpty, focusState == .secureRevealed {
                        HStack {
                            Spacer()

                            Button {
                                secureInputRevealingPassword = false
                                focusState = .secure
                            } label: {
                                Image(systemName: "eye.slash.fill")
                            }
                            .foregroundColor(.secondary.opacity(0.8))
                            .padding(.trailing, 3)
                        }
                    }
                }
            } else {
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
                .focused($focusState, equals: .secure)
                .focusablePadding(.trailing, text.isEmpty ? 0 : 30)
                .foregroundStyle(
                    textColorOverride ?? parraTheme.palette.primaryText
                        .toParraColor()
                )
                .onAppear {
                    if let passwordRuleDescriptor = config
                        .passwordRuleDescriptor,
                        config.isSecure
                    {
                        UITextField.appearance()
                            .passwordRules = UITextInputPasswordRules(
                                descriptor: passwordRuleDescriptor
                            )
                    }
                }
                .overlay {
                    if !text.isEmpty, focusState == .secure {
                        HStack {
                            Spacer()

                            Button {
                                secureInputRevealingPassword = true
                                focusState = .secureRevealed
                            } label: {
                                Image(systemName: "eye.fill")
                            }
                            .foregroundColor(.secondary.opacity(0.8))
                            .padding(.trailing, 3)
                        }
                    }
                }
            }
        } else {
            TextField(
                text: $text,
                prompt: prompt
            ) {
                EmptyView()
            }
            .focused($focusState, equals: .normal)
            .focusablePadding(.trailing, text.isEmpty ? 0 : 30)
            .overlay {
                if !text.isEmpty, focusState == .normal {
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
        }
    }

    // MARK: - Private

    @Environment(\.parraComponentFactory) private var componentFactory

    @FocusState private var focusState: FocusField?
    @State private var lastFocusState: FocusField?

    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.parraTheme) private var parraTheme

    @State private var text: String
    @State private var hasReceivedInput = false
    @State private var secureInputRevealingPassword = false

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
            ParraLabelContent(text: message)
        } else {
            ParraLabelContent(text: "")
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
                config: ParraTextInputConfig(),
                content: ParraTextInputContent(
                    title: "Some title",
                    placeholder: "temp placeholder",
                    helper: "helper text woo",
                    errorMessage: nil,
                    textChanged: nil
                )
            )

            factory.buildTextInput(
                config: ParraTextInputConfig(),
                content: ParraTextInputContent(
                    title: "Some title",
                    placeholder: "temp placeholder",
                    helper: "helper text woo",
                    errorMessage: nil,
                    textChanged: nil
                )
            )

            factory.buildTextInput(
                config: ParraTextInputConfig(),
                content: ParraTextInputContent(
                    title: "Some title",
                    placeholder: "",
                    helper: "helper text woo",
                    errorMessage: "That text isn't very good",
                    textChanged: nil
                )
            )

            factory.buildTextInput(
                config: ParraTextInputConfig(),
                content: ParraTextInputContent(
                    title: "Some title",
                    placeholder: nil,
                    helper: "helper text woo",
                    errorMessage: nil,
                    textChanged: nil
                )
            )

            factory.buildTextInput(
                config: ParraTextInputConfig(
                    validationRules: [.hasLowercase, .hasUppercase],
                    isSecure: true
                ),
                content: ParraTextInputContent(
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

extension View {
    func focusablePadding(
        _ edges: Edge.Set = .all,
        _ size: CGFloat? = nil
    ) -> some View {
        modifier(FocusablePadding(edges, size))
    }
}

private struct FocusablePadding: ViewModifier {
    // MARK: - Lifecycle

    init(_ edges: Edge.Set, _ size: CGFloat?) {
        self.edges = edges
        self.size = size
        self.focused = false
    }

    // MARK: - Internal

    func body(content: Content) -> some View {
        content
            .focused($focused)
            .padding(edges, size)
            .contentShape(Rectangle())
            .onTapGesture { focused = true }
    }

    // MARK: - Private

    private let edges: Edge.Set
    private let size: CGFloat?
    @FocusState private var focused: Bool
}
