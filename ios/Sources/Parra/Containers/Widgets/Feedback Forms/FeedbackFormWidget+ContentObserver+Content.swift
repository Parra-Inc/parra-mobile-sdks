//
//  FeedbackFormWidget+ContentObserver+Content.swift
//  Parra
//
//  Created by Mick MacCallum on 2/25/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Foundation

extension FeedbackFormWidget.ContentObserver {
    struct Content: ParraContainerContent {
        // MARK: - Lifecycle

        init(
            title: ParraLabelContent,
            description: ParraLabelContent?,
            contextMessage: ParraLabelContent?,
            fields: [FormFieldWithState],
            submitButton: ParraTextButtonContent
        ) {
            self.title = title
            self.description = description
            self.contextMessage = contextMessage
            self.fields = fields
            // Additional call on init to handle the case where there none of the fields
            // are marked as required, so their default state is valid.
            self.canSubmit = Content.areAllFieldsValid(
                fields: fields
            )
            self.submitButton = ParraTextButtonContent(
                text: submitButton.text,
                isDisabled: !canSubmit
            )
        }

        // MARK: - Internal

        let title: ParraLabelContent
        let description: ParraLabelContent?
        let contextMessage: ParraLabelContent?

        var fields: [FormFieldWithState]

        var submitButton: ParraTextButtonContent

        var canSubmit: Bool

        func withUpdates(
            to fields: [FormFieldWithState]
        ) -> Content {
            Content(
                title: title,
                description: description,
                contextMessage: contextMessage,
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
