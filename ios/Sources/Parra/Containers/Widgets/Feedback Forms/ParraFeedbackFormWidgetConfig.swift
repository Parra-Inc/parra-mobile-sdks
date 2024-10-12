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

    public required init() {
        self.maxTextFieldCharacters = ParraFeedbackFormWidgetConfig.default
            .maxTextFieldCharacters
    }

    public init(
        maxTextFieldCharacters: Int = ParraFeedbackFormWidgetConfig.default
            .maxTextFieldCharacters
    ) {
        self.maxTextFieldCharacters = maxTextFieldCharacters
    }

    // MARK: - Public

    public static let `default` = ParraFeedbackFormWidgetConfig(
        maxTextFieldCharacters: 30
    )

    /// The maximum number of characters allowed in a text field input.
    public let maxTextFieldCharacters: Int
}
