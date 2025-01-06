//
//  ParraFeedbackFormWidgetConfig.swift
//  Parra
//
//  Created by Mick MacCallum on 1/28/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

public class ParraFeedbackFormWidgetConfig: ParraContainerConfig {
    // MARK: - Lifecycle

    public init(
        maxTextFieldCharacters: Int = ParraFeedbackFormWidgetConfig.default
            .maxTextFieldCharacters,
        defaultValues: [String: String] = ParraFeedbackFormWidgetConfig.default
            .defaultValues,
        contextMessage: String? = ParraFeedbackFormWidgetConfig.default.contextMessage
    ) {
        self.maxTextFieldCharacters = maxTextFieldCharacters
        self.defaultValues = defaultValues
        self.contextMessage = contextMessage
    }

    // MARK: - Public

    public static let `default` = ParraFeedbackFormWidgetConfig(
        maxTextFieldCharacters: 30,
        defaultValues: [:],
        contextMessage: nil
    )

    /// The maximum number of characters allowed in a text field input.
    public let maxTextFieldCharacters: Int

    /// The default values that will be added to each field in the form, keyed
    /// by the "name" for the field in the Parra dashboard.
    public let defaultValues: [String: String]

    public let contextMessage: String?
}
