//
//  FeedbackFormViewState.swift
//  Parra
//
//  Created by Mick MacCallum on 1/19/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Foundation
import SwiftUI

fileprivate let logger = Logger(category: "FeedbackFormViewState")

@MainActor
final internal class FeedbackFormViewState: ObservableObject {
    internal let title: String
    internal let description: String?
    
    @Published
    internal var fields: [FormFieldWithState]

    @Published 
    internal var canSubmit = false

    private let submissionHandler: (([FeedbackFormField : String]) -> Void)?

    internal init(
        formData: FeedbackFormData,
        config: ParraCardViewConfig,
        submissionHandler: (([FeedbackFormField : String]) -> Void)? = nil
    ) {
        title = formData.title
        description = formData.description
        fields = formData.fields.map { FormFieldWithState(field: $0) }

        self.submissionHandler = submissionHandler

        // Additional call on init to handle the case where there none of the fields
        // are marked as required, so their default state is valid.
        canSubmit = FeedbackFormViewState.areAllFieldsValid(
            fields: fields
        )
    }

    internal func onFieldValueChanged(
        field: FeedbackFormField,
        value: String?
    ) {
        guard let updateIndex = fields.firstIndex(
            where: { $0.id == field.id }
        ) else {
            logger.warn("Received event for update to unknown field", [
                "fieldId": field.id
            ])

            return
        }

        var updatedFields = fields
        var changedField = updatedFields[updateIndex]
        changedField.updateValue(value)
        updatedFields[updateIndex] = changedField

        fields = updatedFields

        canSubmit = FeedbackFormViewState.areAllFieldsValid(
            fields: fields
        )
    }

    internal func submit() {
        let data = fields.reduce([FeedbackFormField : String]()) { accumulator, fieldWithState in
            guard let value = fieldWithState.value else {
                return accumulator
            }

            var next = accumulator
            next[fieldWithState.field] = value
            return next
        }

        submissionHandler?(data)
    }

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
