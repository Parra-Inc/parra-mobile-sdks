//
//  FormFieldWithState.swift
//  Parra
//
//  Created by Mick MacCallum on 1/19/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Foundation

internal struct FormFieldWithState: Identifiable {
    internal let field: FeedbackFormField
    
    internal private(set) var state: FormFieldState
    internal private(set) var value: String?

    var id: String {
        return field.id
    }

    init(
        field: FeedbackFormField
    ) {
        self.field = field
        self.state = Self.validateUpdate(value: nil, for: field)
        self.value = nil
    }

    mutating func updateValue(_ value: String?) {
        self.value = value
        self.state = Self.validateUpdate(value: value, for: field)
    }

    private static func validateUpdate(
        value: String?,
        for field: FeedbackFormField
    ) -> FormFieldState {
        switch field.data {
        case .feedbackFormTextFieldData(let data):
            var rules = [TextValidatorRule]()

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
        case .feedbackFormInputFieldData:
            // TODO: Implement when support for input fields is added.
            return .invalid("Input fields are not supported yet!")
        }
    }
}
