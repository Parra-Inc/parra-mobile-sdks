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
        title: LabelConfig = TextInputConfig.default.title,
        helper: LabelConfig = TextInputConfig.default.helper,
        validationRules: [TextValidatorRule] = TextInputConfig.default
            .validationRules,
        preferValidationErrorsToHelperMessage: Bool = TextInputConfig.default
            .preferValidationErrorsToHelperMessage,
        isSecure: Bool = false,
        contentType: UITextContentType? = nil
    ) {
        self.title = title
        self.helper = helper
        self.validationRules = validationRules
        self.preferValidationErrorsToHelperMessage
            = preferValidationErrorsToHelperMessage
        self.isSecure = isSecure
        self.contentType = contentType
    }

    // MARK: - Public

    public static let `default` = TextInputConfig(
        title: LabelConfig(fontStyle: .body),
        helper: LabelConfig(fontStyle: .subheadline),
        validationRules: [],
        preferValidationErrorsToHelperMessage: true
    )

    public let title: LabelConfig
    public let helper: LabelConfig

    public let validationRules: [TextValidatorRule]

    /// Whether or not to show validation errors if any exist in place of the
    /// helper text string. If you don't want to display anything below the text
    /// field, set this to false and leave ``helper`` unset.
    public let preferValidationErrorsToHelperMessage: Bool

    /// Whether or not the text field should be secure. Defaults to false.
    /// If true, the text field will display a secure entry view for passwords.
    public let isSecure: Bool

    /// The content type applied to the text field for determining which
    /// information to autofill/etc.
    public let contentType: UITextContentType?

    // MARK: - Internal

    func withFormTextFieldData(
        _ data: FeedbackFormInputFieldData
    ) -> TextInputConfig {
        return self
    }
}
