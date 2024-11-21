//
//  FeedbackFormWidget.swift
//  Parra
//
//  Created by Mick MacCallum on 1/28/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

struct FeedbackFormWidget: ParraContainer {
    // MARK: - Lifecycle

    init(
        config: ParraFeedbackFormWidgetConfig,
        contentObserver: ContentObserver
    ) {
        self.config = config
        self._contentObserver = StateObject(wrappedValue: contentObserver)
    }

    // MARK: - Internal

    @StateObject var contentObserver: ContentObserver
    let config: ParraFeedbackFormWidgetConfig

    var body: some View {
        let defaultWidgetAttributes = ParraAttributes.Widget.default(
            with: parraTheme
        )

        let contentPadding = parraTheme.padding.value(
            for: defaultWidgetAttributes.contentPadding
        )

        VStack(alignment: .leading, spacing: 0) {
            ScrollView {
                if let descriptionContent = contentObserver.content.description {
                    componentFactory.buildLabel(
                        content: descriptionContent,
                        localAttributes: .default(with: .subheadline)
                    )
                    .padding(.bottom, 16)
                    .frame(
                        maxWidth: .infinity,
                        alignment: .leading
                    )
                }

                fieldViews
            }
            .contentMargins(
                .all,
                .padding(
                    bottom: contentPadding.bottom
                ),
                for: .scrollContent
            )
            .scrollDismissesKeyboard(.interactively)

            WidgetFooter(
                primaryActionBuilder: {
                    componentFactory.buildContainedButton(
                        config: ParraTextButtonConfig(
                            type: .primary,
                            size: .large,
                            isMaxWidth: true
                        ),
                        content: contentObserver.content.submitButton,
                        onPress: {
                            contentObserver.submit()
                        }
                    )
                    .disabled(!contentObserver.content.canSubmit)
                },
                secondaryActionBuilder: nil,
                contentPadding: .padding(
                    top: contentPadding.top,
                    bottom: contentPadding.bottom
                )
            )
        }
        .safeAreaPadding(.horizontal)
        .navigationTitle(contentObserver.content.title.text)
        .applyWidgetAttributes(
            attributes: defaultWidgetAttributes.withoutContentPadding(),
            using: parraTheme
        )
        .environmentObject(contentObserver)
        .environment(componentFactory)
    }

    var fieldViews: some View {
        VStack(alignment: .leading, spacing: 20) {
            ForEach(contentObserver.content.fields) { fieldWithState in
                let field = fieldWithState.field

                switch field.data {
                case .feedbackFormSelectFieldData(let data):
                    let content = ParraMenuContent(
                        title: field.title,
                        placeholder: data.placeholder,
                        helper: field.helperText,
                        options: data.options.map { fieldOption in
                            ParraMenuContent.Option(
                                id: fieldOption.id,
                                title: fieldOption.title,
                                value: fieldOption.id
                            )
                        }
                    ) { option in
                        onFieldValueChanged(
                            field: field,
                            value: option?.value
                        )
                    }

                    componentFactory.buildMenu(
                        config: ParraMenuConfig(),
                        content: content,
                        localAttributes: ParraAttributes.Menu(
                            padding: .zero
                        )
                    )
                case .feedbackFormTextFieldData(let data):
                    let content = ParraTextEditorContent(
                        title: field.title,
                        placeholder: data.placeholder,
                        helper: field.helperText,
                        errorMessage: fieldWithState.state.errorMessage
                    ) { newText in
                        onFieldValueChanged(
                            field: field,
                            value: newText
                        )
                    }

                    componentFactory.buildTextEditor(
                        config: ParraTextEditorConfig(
                            maxCharacters: 30,
                            shouldAutoFocus: fieldWithState.shouldAutoFocus
                        ),
                        content: content,
                        localAttributes: ParraAttributes.TextEditor(
                            padding: .zero
                        )
                    )
                case .feedbackFormInputFieldData(let data):
                    let content = ParraTextInputContent(
                        title: field.title,
                        placeholder: data.placeholder,
                        helper: field.helperText,
                        errorMessage: fieldWithState.state.errorMessage
                    ) { newText in
                        onFieldValueChanged(
                            field: field,
                            value: newText
                        )
                    }

                    componentFactory.buildTextInput(
                        config: ParraTextInputConfig(
                            shouldAutoFocus: fieldWithState.shouldAutoFocus
                        ),
                        content: content,
                        localAttributes: ParraAttributes.TextInput(
                            padding: .zero
                        )
                    )
                }
            }
        }
    }

    // MARK: - Private

    @Environment(\.parraComponentFactory) private var componentFactory
    @Environment(\.parraTheme) private var parraTheme

    private func onFieldValueChanged(
        field: ParraFeedbackFormField,
        value: String?
    ) {
        contentObserver.onFieldValueChanged(
            field: field,
            value: value
        )
    }
}

#Preview {
    ParraContainerPreview<FeedbackFormWidget>(
        config: .default
    ) { _, _, config in
        FeedbackFormWidget(
            config: config,
            contentObserver: .init(
                initialParams: .init(
                    formData: .init(
                        title: "Leave feedback",
                        description: "We'd love to hear from you. Your input helps us make our product better.",
                        fields: ParraFeedbackFormField.validStates()
                    )
                )
            )
        )
    }
}
