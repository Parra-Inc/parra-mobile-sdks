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
    class ContentObserver: ContainerContentObserver {
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

            let submitButton = ParraTextButtonContent(
                text: ParraLabelContent(text: "Submit"),
                isDisabled: false
            )

            var hasSetAutoFocusField = false

            self.content = Content(
                title: ParraLabelContent(text: formData.title),
                description: description,
                fields: formData.fields.elements.map { field in
                    // We only want the first focusable field to auto-focus.
                    let isInput = field.type == .text || field.type == .input
                    let shouldAutoFocus = isInput && !hasSetAutoFocusField

                    if shouldAutoFocus {
                        hasSetAutoFocusField = true
                    }

                    return FormFieldWithState(
                        field: field,
                        shouldAutoFocus: shouldAutoFocus
                    )
                },
                submitButton: submitButton
            )
        }

        // MARK: - Internal

        @Published var content: Content

        var submissionHandler: (([ParraFeedbackFormField: String]) -> Void)?

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

        func submit() {
            let data = content.fields
                .reduce(
                    [ParraFeedbackFormField: String]()
                ) { accumulator, fieldWithState in
                    guard let value = fieldWithState.value else {
                        return accumulator
                    }

                    var next = accumulator
                    next[fieldWithState.field] = value
                    return next
                }

            submissionHandler?(data)
        }
    }
}
