//
//  FeedbackFormWidget.swift
//  Parra
//
//  Created by Mick MacCallum on 1/28/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

struct FeedbackFormWidget: Container {
    typealias Factory = FeedbackFormWidgetComponentFactory
    typealias Config = FeedbackFormConfig
    typealias ContentObserver = FeedbackFormContentObserver
    typealias Style = WidgetStyle

    var componentFactory: ComponentFactory<Factory>

    var config: Config

    @StateObject
    var contentObserver: FeedbackFormContentObserver

    @StateObject
    var themeObserver: ParraThemeObserver

    private func onFieldValueChanged(
        field: FeedbackFormField,
        value: String?
    ) {
        
        contentObserver.onFieldValueChanged(
            field: field,
            value: value
        )
    }

    var header: some View {
        VStack(alignment: .leading, spacing: 10) {
            componentFactory.buildLabel(
                component: \.title,
                config: config.title,
                content: contentObserver.content.title,
                localAttributes: nil
            )

            componentFactory.buildLabel(
                component: \.description,
                config: config.description,
                content: contentObserver.content.description,
                localAttributes: nil
            )
        }
    }

    var fieldViews: some View {
        VStack(alignment: .leading, spacing: 20) {
            ForEach(contentObserver.content.fields) { fieldWithState in
                let field = fieldWithState.field

                switch field.data {
                case .feedbackFormSelectFieldData(let data):
                    let content = MenuContent(
                        label: LabelContent(
                            text: field.title ?? "Select an option"
                        ),
                        options: data.options.map { fieldOption in
                            MenuComponent.Option(
                                id: fieldOption.id,
                                title: fieldOption.title,
                                value: fieldOption.id
                            )
                        }
                    ) { option in
                        self.onFieldValueChanged(
                            field: field,
                            value: option?.value
                        )
                    }

                    componentFactory.buildMenu(
                        component: \.selectFields,
                        config: config.selectFields,
                        content: content,
                        localAttributes: nil
                    )
                case .feedbackFormTextFieldData(let data):

                    let content = TextEditorContent(
                        placeholder: data.placeholder,
                        errorMessage: fieldWithState.state.errorMessage
                    ) { newText in
                        self.onFieldValueChanged(
                            field: field,
                            value: newText
                        )
                    }

                    componentFactory.buildTextEditor(
                        component: \.textFields,
                        config: config.textFields,
                        content: content,
                        localAttributes: nil
                    )
                }
            }
        }
    }

    var footer: some View {
        VStack(alignment: .center, spacing: 16) {
            componentFactory.buildButton(
                variant: .contained,
                component: \.submitButton,
                config: config.submitButton,
                content: contentObserver.content.submitButton,
                localAttributes: .init()
            )
            .disabled(!contentObserver.content.canSubmit)

            ParraLogoButton(type: .poweredBy)
        }
    }


    var body: some View {
        withEnvironmentObjects {
            VStack(alignment: .leading) {
                VStack(alignment: .leading, spacing: 20) {
                    header

                    fieldViews
                }
                .layoutPriority(100)

                Spacer()
                    .layoutPriority(0)

                footer
            }
            .background(themeObserver.theme.palette.primaryBackground)
            .safeAreaPadding()
        }
    }
}

#Preview {
    let global = GlobalComponentAttributes(
        labelAttributeFactory: { config, content, defaultAttributes in
            return defaultAttributes ?? .init()
        },
        buttonAttributeFactory: { config, content, defaultAttributes in
            return defaultAttributes ?? .init()
        }
    )

    let local = FeedbackFormWidgetComponentFactory(
        titleBuilder: nil,
        descriptionBuilder: { config, content, attributes in
            if let content {
                Text(content.text)
                    .font(.subheadline)
            } else {
                nil
            }
        },
        submitButtonBuilder: nil
    )

    return FeedbackFormWidget(
        componentFactory: .init(
            local: local,
            global: global,
            theme: ParraTheme.default
        ),
        config: .init(
            title: LabelConfig(type: .title),
            description: LabelConfig(type: .description),
            selectFields: MenuConfig(label: LabelConfig(type: .body)),
            textFields: TextEditorConfig(maxCharacters: 50),
            submitButton: .init(
                style: .primary,
                size: .large,
                isMaxWidth: true,
                title: LabelConfig(type: .description)
            )
        ),
        contentObserver: .init(
            formData: .init(
                title: "Leave feedback",
                description: "We'd love to hear from you. Your input helps us make our product better.",
                fields: [
                    .init(
                        name: "type",
                        title: "Type of Feedback",
                        helperText: nil,
                        type: .select,
                        required: true,
                        data: .feedbackFormSelectFieldData(
                            FeedbackFormSelectFieldData(
                                placeholder: "Please select an option",
                                options: [
                                    FeedbackFormSelectFieldOption(
                                        title: "General feedback",
                                        value: "general-feedback",
                                        isOther: nil
                                    ),
                                    FeedbackFormSelectFieldOption(
                                        title: "Bug report",
                                        value: "bug-report",
                                        isOther: nil
                                    ),
                                    FeedbackFormSelectFieldOption(
                                        title: "Feature request",
                                        value: "feature-request",
                                        isOther: nil
                                    ),
                                    FeedbackFormSelectFieldOption(
                                        title: "Idea",
                                        value: "idea",
                                        isOther: nil
                                    ),
                                    FeedbackFormSelectFieldOption(
                                        title: "Other",
                                        value: "other",
                                        isOther: nil
                                    ),
                                ]
                            )
                        )
                    ),
                    .init(
                        name: "response",
                        title: "Your Feedback",
                        helperText: nil,
                        type: .text,
                        required: true,
                        data: .feedbackFormTextFieldData(
                            FeedbackFormTextFieldData(
                                placeholder: "placeholder",
                                lines: 5,
                                maxLines: 10,
                                minCharacters: 20,
                                maxCharacters: 420,
                                maxHeight: 200
                            )
                        )
                    )
                ]
            )
        ),
        themeObserver: .init(
            theme: .default,
            notificationCenter: ParraNotificationCenter()
        )
    )
}
