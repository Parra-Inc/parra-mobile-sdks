//
//  FeedbackFormWidget+ContentObserver.swift
//  Parra
//
//  Created by Mick MacCallum on 1/28/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

private let logger = Logger()

// MARK: - FeedbackFormWidget.ContentObserver

extension FeedbackFormWidget {
    class ContentObserver: ParraContainerContentObserver {
        // MARK: - Lifecycle

        required init(
            initialParams: InitialParams
        ) {
            let formData = initialParams.formData

            let description: ParraLabelContent? = if let formDescription = formData
                .description
            {
                ParraLabelContent(text: formDescription)
            } else {
                nil
            }

            let contextMessage: ParraLabelContent? = if let message = initialParams.config
                .contextMessage
            {
                ParraLabelContent(text: message)
            } else {
                nil
            }

            let submitButton = ParraTextButtonContent(
                text: ParraLabelContent(text: "Submit"),
                isDisabled: false
            )

            var hasSetAutoFocusField = false

            self.content = Content(
                title: ParraLabelContent(text: formData.title),
                description: description,
                contextMessage: contextMessage,
                fields: formData.fields.elements.map { field in
                    // We only want the first focusable field to auto-focus.
                    let isInput = field.type == .text || field.type == .input
                    let shouldAutoFocus = isInput && !hasSetAutoFocusField && !UIDevice
                        .isIpad

                    if shouldAutoFocus {
                        hasSetAutoFocusField = true
                    }

                    return FormFieldWithState(
                        field: field,
                        initialValue: initialParams.config
                            .defaultValues[field.id],
                        shouldAutoFocus: shouldAutoFocus
                    )
                },
                submitButton: submitButton
            )
        }

        // MARK: - Internal

        @Published var content: Content

        var submissionHandler: (([ParraFeedbackFormField: String]) async -> Void)?

        func onFieldValueChanged(
            field: ParraFeedbackFormField,
            value: String?
        ) {
            guard let updateIndex = content.fields.firstIndex(
                where: { $0.id == field.id }
            ) else {
                logger.warn("Received event for update to unknown field", [
                    "fieldId": field.id
                ])

                return
            }

            var updatedFields = content.fields
            var changedField = updatedFields[updateIndex]
            changedField.updateValue(value)
            updatedFields[updateIndex] = changedField

            content = content.withUpdates(
                to: updatedFields
            )
        }

        @MainActor
        func submit() async {
            let data = content.fields.reduce(
                [ParraFeedbackFormField: String]()
            ) { accumulator, fieldWithState in
                guard let value = fieldWithState.value else {
                    return accumulator
                }

                var next = accumulator
                next[fieldWithState.field] = value
                return next
            }

            guard let submissionHandler else {
                logger.warn("Feedback form has no submission handler")

                return
            }

            content.submitButton = content.submitButton.withLoading(true)

            await submissionHandler(data)

            content.submitButton = content.submitButton.withLoading(false)
        }
    }
}
