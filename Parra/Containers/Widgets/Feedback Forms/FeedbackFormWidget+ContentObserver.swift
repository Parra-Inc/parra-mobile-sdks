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
    @MainActor
    class ContentObserver: ContainerContentObserver {
        // MARK: - Lifecycle

        required init(
            initialParams: InitialParams
        ) {
            let formData = initialParams.formData

            let description: LabelContent? = if let formDescription = formData
                .description
            {
                LabelContent(text: formDescription)
            } else {
                nil
            }

            let submitButton = TextButtonContent(
                text: LabelContent(text: "Submit"),
                isDisabled: false
            )

            self.content = Content(
                title: LabelContent(text: formData.title),
                description: description,
                fields: formData.fields.map { FormFieldWithState(field: $0) },
                submitButton: submitButton
            )
        }

        // MARK: - Internal

        @Published var content: Content

        var submissionHandler: (([FeedbackFormField: String]) -> Void)?

        func onFieldValueChanged(
            field: FeedbackFormField,
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
                    [FeedbackFormField: String]()
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
