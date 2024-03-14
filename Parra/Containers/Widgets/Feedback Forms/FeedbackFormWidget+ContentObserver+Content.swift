//
//  FeedbackFormWidget+ContentObserver+Content.swift
//  Parra
//
//  Created by Mick MacCallum on 2/25/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Foundation

extension FeedbackFormWidget.ContentObserver {
    @MainActor
    struct Content: ContainerContent {
        // MARK: - Lifecycle

        init(
            title: LabelContent,
            description: LabelContent?,
            fields: [FormFieldWithState],
            submitButton: TextButtonContent
        ) {
            self.title = title
            self.description = description
            self.fields = fields
            // Additional call on init to handle the case where there none of the fields
            // are marked as required, so their default state is valid.
            self.canSubmit = Content.areAllFieldsValid(
                fields: fields
            )
            self.submitButton = TextButtonContent(
                text: submitButton.text,
                isDisabled: !canSubmit
            )
        }

        // MARK: - Internal

        let title: LabelContent
        let description: LabelContent?

        var fields: [FormFieldWithState]

        var submitButton: TextButtonContent

        var canSubmit: Bool

        func withUpdates(
            to fields: [FormFieldWithState]
        ) -> Content {
            Content(
                title: title,
                description: description,
                fields: fields,
                submitButton: submitButton
            )
        }

        // MARK: - Private

        private static func areAllFieldsValid(
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
}
