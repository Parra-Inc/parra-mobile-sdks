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

//                switch field.data {
//                case .feedbackFormSelectFieldData(let data):
//                    ParraFeedbackFormSelectFieldView(
//                        fieldWithState: fieldWithState,
//                        fieldData: .init(data: data),
//                        onFieldValueChanged: self.onFieldValueChanged
//                    )
//                case .feedbackFormTextFieldData(let data):
//                    ParraFeedbackFormTextFieldView(
//                        fieldWithState: fieldWithState,
//                        fieldData: .init(data: data),
//                        onFieldValueChanged: self.onFieldValueChanged
//                    )
//                }
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
            selectFields: LabelConfig(type: .body),
            textFields: LabelConfig(type: .body),
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
                            FeedbackFormSelectFieldData.validStates()[0]
                        )
                    ),
                    .init(
                        name: "response",
                        title: "Your Feedback",
                        helperText: nil,
                        type: .text,
                        required: true,
                        data: .feedbackFormTextFieldData(
                            FeedbackFormTextFieldData.validStates()[0]
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
