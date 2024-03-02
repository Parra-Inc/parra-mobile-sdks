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
        title: LabelConfig = LabelConfig(fontStyle: .body),
        helper: LabelConfig = LabelConfig(fontStyle: .subheadline),
        showValidationErrors: Bool = TextEditorConfig.default
            .showValidationErrors
    ) {
        self.title = title
        self.helper = helper
        self.showValidationErrors = showValidationErrors
    }

    // MARK: - Public

    public let title: LabelConfig
    public let helper: LabelConfig

    /// Whether or not to show validation errors if any exist in place of the
    /// helper text string. If you don't want to display anything below the text
    /// editor, set this to false and leave ``helper`` unset.
    public let showValidationErrors: Bool

    // MARK: - Internal

    static let `default` = TextEditorConfig(
        title: LabelConfig(fontStyle: .body),
        helper: LabelConfig(fontStyle: .subheadline),
        showValidationErrors: true
    )

    func withFormTextFieldData(
        _ data: FeedbackFormInputFieldData
    ) -> TextInputConfig {
        return self
    }
}
