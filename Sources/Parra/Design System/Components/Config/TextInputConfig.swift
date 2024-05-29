//
//  TextInputConfig.swift
//  Parra
//
//  Created by Mick MacCallum on 2/20/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

public struct TextInputConfig {
    // MARK: - Lifecycle

    public init(
        validationRules: [TextValidatorRule] = TextInputConfig.default
            .validationRules,
        preferValidationErrorsToHelperMessage: Bool = TextInputConfig.default
            .preferValidationErrorsToHelperMessage,
        isSecure: Bool = false,
        keyboardType: UIKeyboardType = .default,
        textCase: Text.Case? = nil,
        textContentType: UITextContentType? = nil,
        textInputAutocapitalization: TextInputAutocapitalization? = nil,
        autocorrectionDisabled: Bool = true,
        passwordRuleDescriptor: String? = nil
    ) {
        self.validationRules = validationRules
        self.preferValidationErrorsToHelperMessage
            = preferValidationErrorsToHelperMessage
        self.isSecure = isSecure
        self.keyboardType = keyboardType
        self.textCase = textCase
        self.textContentType = textContentType
        self.textInputAutocapitalization = textInputAutocapitalization
        self.autocorrectionDisabled = autocorrectionDisabled
        self.passwordRuleDescriptor = passwordRuleDescriptor
    }

    // MARK: - Public

    public static let `default` = TextInputConfig(
        validationRules: [],
        preferValidationErrorsToHelperMessage: true
    )

    public let validationRules: [TextValidatorRule]

    /// Whether or not to show validation errors if any exist in place of the
    /// helper text string. If you don't want to display anything below the text
    /// field, set this to false and leave ``helper`` unset.
    public let preferValidationErrorsToHelperMessage: Bool

    /// Whether or not the text field should be secure. Defaults to false.
    /// If true, the text field will display a secure entry view for passwords.
    public let isSecure: Bool

    public let keyboardType: UIKeyboardType
    public let textCase: Text.Case?
    public let textContentType: UITextContentType?
    public let textInputAutocapitalization: TextInputAutocapitalization?
    public let autocorrectionDisabled: Bool

    /// Custom rules for suggesting passwords for this text input.
    /// See https://developer.apple.com/documentation/security/password_autofill/customizing_password_autofill_rules
    /// for more information.
    /// Note: This is ignored if `isSecure` is false.
    public let passwordRuleDescriptor: String?

    // MARK: - Internal

    func withFormTextFieldData(
        _ data: FeedbackFormInputFieldData
    ) -> TextInputConfig {
        return self
    }
}
