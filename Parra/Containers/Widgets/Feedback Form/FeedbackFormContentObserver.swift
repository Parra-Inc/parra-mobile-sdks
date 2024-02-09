//
//  FeedbackFormContentObserver.swift
//  Parra
//
//  Created by Mick MacCallum on 1/28/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

private let logger = Logger()

@MainActor
class FeedbackFormContentObserver: ContainerContentObserver {
    // MARK: - Lifecycle

    init(
        formData: FeedbackFormData
    ) {
        let description: LabelContent? = if let formDescription = formData
            .description
        {
            LabelContent(text: formDescription)
        } else {
            nil
        }

        let submitButton = ButtonContent(
            title: .init(text: "Submit"),
            isDisabled: false,
            onPress: nil
        )

        self.content = Content(
            title: LabelContent(text: formData.title),
            description: description,
            fields: formData.fields.map { FormFieldWithState(field: $0) },
            submitButton: submitButton
        )

        content.submitButton.onPress = submit
    }

    // MARK: - Internal

    @MainActor
    struct Content: ContainerContent {
        // MARK: - Lifecycle

        init(
            title: LabelContent,
            description: LabelContent?,
            fields: [FormFieldWithState],
            submitButton: ButtonContent
        ) {
            self.title = title
            self.description = description
            self.fields = fields
            // Additional call on init to handle the case where there none of the fields
            // are marked as required, so their default state is valid.
            self.canSubmit = Content.areAllFieldsValid(
                fields: fields
            )
            self.submitButton = ButtonContent(
                title: submitButton.title,
                isDisabled: !canSubmit,
                onPress: submitButton.onPress
            )
        }

        // MARK: - Internal

        let title: LabelContent
        let description: LabelContent?

        fileprivate(set) var fields: [FormFieldWithState]

        fileprivate(set) var submitButton: ButtonContent

        fileprivate(set) var canSubmit: Bool

        // MARK: - Fileprivate

        fileprivate static func areAllFieldsValid(
            fields: [FormFieldWithState]
        ) -> Bool {
            return fields.allSatisfy { fieldState in
                let field = fieldState.field
                let required = field.required ?? false

                // Don't count fields that aren't required.
                guard required else {
                    return true
                }

                switch fieldState.state {
                case .valid:
                    return true
                case .invalid:
                    return false
                }
            }
        }

        fileprivate func withUpdates(
            to fields: [FormFieldWithState]
        ) -> Content {
            Content(
                title: title,
                description: description,
                fields: fields,
                submitButton: submitButton
            )
        }
    }

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

        print("Content changed. Is valid: \(content.canSubmit)")
    }

    // MARK: - Private

    private func submit() {
        let data = content.fields
            .reduce([FeedbackFormField: String](
            )) { accumulator, fieldWithState in
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
