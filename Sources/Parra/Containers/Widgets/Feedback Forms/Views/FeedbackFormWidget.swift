//
//  FeedbackFormWidget.swift
//  Parra
//
//  Created by Mick MacCallum on 1/28/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

struct FeedbackFormWidget: Container {
    // MARK: - Lifecycle

    init(
        config: FeedbackFormWidgetConfig,
        componentFactory: ComponentFactory,
        contentObserver: ContentObserver
    ) {
        self.config = config
        self.componentFactory = componentFactory
        self._contentObserver = StateObject(wrappedValue: contentObserver)
    }

    // MARK: - Internal

    let componentFactory: ComponentFactory
    @StateObject var contentObserver: ContentObserver
    let config: FeedbackFormWidgetConfig

    @EnvironmentObject var themeObserver: ParraThemeObserver

    var body: some View {
        let defaultWidgetAttributes = ParraAttributes.Widget.default(
            with: themeObserver.theme
        )

        let contentPadding = themeObserver.theme.padding.value(
            for: defaultWidgetAttributes.contentPadding
        )

        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    header

                    fieldViews
                }
            }
            .contentMargins(
                .all,
                contentPadding,
                for: .scrollContent
            )
            .scrollDismissesKeyboard(.interactively)

            WidgetFooter(
                primaryActionBuilder: {
                    componentFactory.buildContainedButton(
                        config: TextButtonConfig(
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
                contentPadding: contentPadding
            )
        }
        .applyWidgetAttributes(
            attributes: defaultWidgetAttributes.withoutContentPadding(),
            using: themeObserver.theme
        )
        .environmentObject(contentObserver)
        .environmentObject(componentFactory)
    }

    var header: some View {
        VStack(alignment: .leading, spacing: 10) {
            componentFactory.buildLabel(
                fontStyle: .title,
                content: contentObserver.content.title
            )

            if let descriptionContent = contentObserver.content.description {
                componentFactory.buildLabel(
                    fontStyle: .subheadline,
                    content: descriptionContent
                )
            }
        }
        .applyPadding(
            size: .lg,
            from: themeObserver.theme
        )
    }

    var fieldViews: some View {
        VStack(alignment: .leading, spacing: 20) {
            ForEach(contentObserver.content.fields) { fieldWithState in
                let field = fieldWithState.field

                switch field.data {
                case .feedbackFormSelectFieldData:
                    EmptyView()
//                    let content = MenuContent(
//                        title: field.title,
//                        placeholder: data.placeholder,
//                        helper: field.helperText,
//                        options: data.options.map { fieldOption in
//                            MenuContent.Option(
//                                id: fieldOption.id,
//                                title: fieldOption.title,
//                                value: fieldOption.id
//                            )
//                        }
//                    ) { option in
//                        onFieldValueChanged(
//                            field: field,
//                            value: option?.value
//                        )
//                    }
                ////
//                    componentFactory.buildMenu(
//                        config: config.selectFields.withFormTextFieldData(data),
//                        content: content
//                    )
                case .feedbackFormTextFieldData(let data):
                    let content = TextEditorContent(
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
                        config: TextEditorConfig(
                            maxCharacters: 30
                        ),
                        content: content
                    )
                case .feedbackFormInputFieldData(let data):
                    let content = TextInputContent(
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
                        config: TextInputConfig(),
                        content: content
                    )
                }
            }
        }
    }

    // MARK: - Private

    private func onFieldValueChanged(
        field: FeedbackFormField,
        value: String?
    ) {
        contentObserver.onFieldValueChanged(
            field: field,
            value: value
        )
    }
}

#Preview {
    ParraContainerPreview<FeedbackFormWidget> { _, componentFactory, _ in
        FeedbackFormWidget(
            config: .default,
            componentFactory: componentFactory,
            contentObserver: .init(
                initialParams: .init(
                    formData: .init(
                        title: "Leave feedback",
                        description: "We'd love to hear from you. Your input helps us make our product better.",
                        fields: FeedbackFormField.validStates()
                    )
                )
            )
        )
    }
}
