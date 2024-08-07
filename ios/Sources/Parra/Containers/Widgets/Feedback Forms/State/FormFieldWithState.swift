//
//  FormFieldWithState.swift
//  Parra
//
//  Created by Mick MacCallum on 1/19/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Foundation

struct FormFieldWithState: Identifiable {
    // MARK: - Lifecycle

    init(
        field: ParraFeedbackFormField
    ) {
        self.field = field
        self.state = Self.validateUpdate(value: nil, for: field)
        self.value = nil
    }

    // MARK: - Internal

    let field: ParraFeedbackFormField

    private(set) var state: FieldState
    private(set) var value: String?

    var id: String {
        return field.id
    }

    mutating func updateValue(_ value: String?) {
        self.value = value
        state = Self.validateUpdate(value: value, for: field)
    }

    // MARK: - Private

    private static func validateUpdate(
        value: String?,
        for field: ParraFeedbackFormField
    ) -> FieldState {
        switch field.data {
        case .feedbackFormInputFieldData:
            return if value == nil {
                .invalid("No input has been provided.")
            } else {
                .valid
            }
        case .feedbackFormTextFieldData(let data):
            var rules = [ParraTextValidatorRule]()

            if let minCharacters = data.minCharacters {
                rules.append(.minLength(minCharacters))
            }

            if let maxCharacters = data.maxCharacters {
                rules.append(.maxLength(maxCharacters))
            }

            let errorMessage = TextValidator.validate(
                text: value,
                against: rules
            )

            return if let errorMessage {
                .invalid(errorMessage)
            } else {
                .valid
            }
        case .feedbackFormSelectFieldData:
            return if value == nil {
                .invalid("No selection has been made.")
            } else {
                .valid
            }
        }
    }
}
