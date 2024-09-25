//
//  ParraTextInputConfig.swift
//  Parra
//
//  Created by Mick MacCallum on 2/20/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

public struct ParraTextInputConfig {
    // MARK: - Lifecycle

    public init(
        validationRules: [ParraTextValidatorRule] = ParraTextInputConfig.default
            .validationRules,
        preferValidationErrorsToHelperMessage: Bool = ParraTextInputConfig.default
            .preferValidationErrorsToHelperMessage,
        resizeWhenHelperMessageIsVisible: Bool = false,
        isSecure: Bool = false,
        keyboardType: UIKeyboardType = .default,
        textCase: Text.Case? = nil,
        textContentType: UITextContentType? = nil,
        textInputAutocapitalization: TextInputAutocapitalization? = nil,
        autocorrectionDisabled: Bool = true,
        passwordRuleDescriptor: String? = nil,
        shouldAutoFocus: Bool = true
    ) {
        self.validationRules = validationRules
        self.preferValidationErrorsToHelperMessage
            = preferValidationErrorsToHelperMessage
        self.resizeWhenHelperMessageIsVisible = resizeWhenHelperMessageIsVisible
        self.isSecure = isSecure
        self.keyboardType = keyboardType
        self.textCase = textCase
        self.textContentType = textContentType
        self.textInputAutocapitalization = textInputAutocapitalization
        self.autocorrectionDisabled = autocorrectionDisabled
        self.passwordRuleDescriptor = passwordRuleDescriptor
        self.shouldAutoFocus = shouldAutoFocus
    }

    // MARK: - Public

    public static let `default` = ParraTextInputConfig(
        validationRules: [],
        preferValidationErrorsToHelperMessage: true
    )

    public let validationRules: [ParraTextValidatorRule]

    /// Whether or not to show validation errors if any exist in place of the
    /// helper text string. If you don't want to display anything below the text
    /// field, set this to false and leave ``helper`` unset.
    public let preferValidationErrorsToHelperMessage: Bool

    /// Whether the total size of the text input will change based on the
    /// presence or absence of the helper message. Defaults to false.
    public let resizeWhenHelperMessageIsVisible: Bool

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

    /// Whether the text input should attempt to auto present the keyboard.
    public let shouldAutoFocus: Bool

    // MARK: - Internal

    func withFormTextFieldData(
        _ data: ParraFeedbackFormInputFieldData
    ) -> ParraTextInputConfig {
        return self
    }
}
