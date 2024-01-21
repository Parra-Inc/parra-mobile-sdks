//
//  FeedbackFormContentObserver.swift
//  Parra
//
//  Created by Mick MacCallum on 1/28/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

fileprivate let logger = Logger()

@MainActor
internal class FeedbackFormContentObserver: ContainerContentObserver {

    @MainActor
    internal struct Content: ContainerContent {

        internal let title: TextContent
        internal let description: TextContent?

        internal fileprivate(set) var fields: [FormFieldWithState]

        internal fileprivate(set) var submitButton: ButtonContent

        internal fileprivate(set) var canSubmit: Bool

        init(
            title: TextContent,
            description: TextContent?,
            fields: [FormFieldWithState],
            submitButton: ButtonContent
        ) {
            self.title = title
            self.description = description
            self.fields = fields
            self.submitButton = submitButton
            // Additional call on init to handle the case where there none of the fields
            // are marked as required, so their default state is valid.
            self.canSubmit = Content.areAllFieldsValid(
                fields: fields
            )
        }

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
    }

    @Published
    var content: Content

    private var submissionHandler: (([FeedbackFormField : String]) -> Void)?

    internal init(
        formData: FeedbackFormData
    ) {
        let description: TextContent? = if let formDescription = formData.description {
            TextContent(text: formDescription)
        } else {
            nil
        }

        let submitButton = ButtonContent(
            title: .init(text: "Submit"),
            isDisabled: false,
            onPress: nil
        )

        self.content = Content(
            title: TextContent(text: formData.title),
            description: description,
            fields: formData.fields.map { FormFieldWithState(field: $0) },
            submitButton: submitButton
        )

        self.content.submitButton.onPress = submit
    }

    internal func onFieldValueChanged(
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

        content.fields = updatedFields

        content.canSubmit = Content.areAllFieldsValid(
            fields: content.fields
        )
    }

    private func submit() {
        let data = content.fields.reduce([FeedbackFormField : String]()) { accumulator, fieldWithState in
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
