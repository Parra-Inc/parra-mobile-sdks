//
//  TextEditorComponent.swift
//  Parra
//
//  Created by Mick MacCallum on 2/5/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

struct TextEditorComponent: View {
    // MARK: - Lifecycle

    init(
        config: ParraTextEditorConfig,
        content: ParraTextEditorContent,
        attributes: ParraAttributes.TextEditor
    ) {
        self.config = config
        self.content = content
        self.attributes = attributes
    }

    // MARK: - Internal

    let config: ParraTextEditorConfig
    let content: ParraTextEditorContent
    let attributes: ParraAttributes.TextEditor

    @EnvironmentObject var componentFactory: ComponentFactory

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // spacing controlled by individual component padding.
            titleLabel

            ZStack {
                TextEditor(text: $text)
                    .applyTextEditorAttributes(
                        attributes,
                        using: themeManager.theme
                    )
                    .contentMargins(
                        .all,
                        Constant.contentInsets,
                        for: .automatic
                    )
                    .onChange(of: text) { _, newValue in
                        hasReceivedInput = true

                        content.textChanged?(newValue)
                    }

                placeholder

                characterCount
            }

            helperLabel
        }
        .applyPadding(size: attributes.padding, from: themeManager.theme)
        .applyBackground(attributes.background)
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

    @EnvironmentObject private var themeManager: ParraThemeManager
    @State private var text = ""
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

    @ViewBuilder private var placeholder: some View {
        if let placeholder = content.placeholder, text.isEmpty {
            Text(placeholder.text)
                .frame(
                    maxWidth: .infinity,
                    maxHeight: .infinity,
                    alignment: .topLeading
                )
                .padding(Constant.primaryTextPadding)
                .applyTextAttributes(
                    attributes.placeholderText,
                    using: themeManager.theme
                )
                .allowsHitTesting(false)
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

        let helperAttributes = isError
            ? attributes.errorLabel : attributes.helperLabel

        componentFactory.buildLabel(
            content: content,
            localAttributes: helperAttributes
        )
    }

    @ViewBuilder private var characterCount: some View {
        if config.showCharacterCountLabel {
            let (count, _) = characterCountString(
                with: config.maxCharacters
            )

            VStack {
                componentFactory.buildLabel(
                    content: ParraLabelContent(text: count),
                    localAttributes: attributes.characterCountLabel
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
            return (String(characterCount), true)
        }

        return ("\(characterCount)/\(max)", characterCount <= max)
    }
}

#Preview {
    ParraViewPreview { factory in
        VStack {
            factory.buildTextEditor(
                config: ParraTextEditorConfig(),
                content: ParraTextEditorContent(
                    title: "Some title",
                    placeholder: "Temp placeholder",
                    helper: "helper text woo",
                    errorMessage: nil,
                    textChanged: nil
                )
            )

            factory.buildTextEditor(
                config: ParraTextEditorConfig(),
                content: ParraTextEditorContent(
                    title: "Some title",
                    placeholder: "temp placeholder",
                    helper: "helper text woo",
                    errorMessage: nil,
                    textChanged: nil
                )
            )

            factory.buildTextEditor(
                config: ParraTextEditorConfig(),
                content: ParraTextEditorContent(
                    title: "Some title",
                    placeholder: "temp placeholder",
                    helper: "helper text woo",
                    errorMessage: "That text isn't very good",
                    textChanged: nil
                )
            )

            factory.buildTextEditor(
                config: ParraTextEditorConfig(),
                content: ParraTextEditorContent(
                    title: "Some title",
                    placeholder: "temp placeholder",
                    helper: "helper text woo",
                    errorMessage: nil,
                    textChanged: nil
                )
            )
        }
    }
    .padding()
}
