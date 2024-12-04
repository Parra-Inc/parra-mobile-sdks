//
//  ParraMenuContent.swift
//  Parra
//
//  Created by Mick MacCallum on 2/5/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

public struct ParraMenuContent {
    // MARK: - Lifecycle

    public init(
        title: ParraLabelContent? = nil,
        placeholder: ParraLabelContent? = nil,
        helper: ParraLabelContent? = nil,
        errorMessage: String? = nil,
        options: [Option],
        optionSelectionChanged: ((Option?) -> Void)? = nil
    ) {
        self.title = title
        self.placeholder = placeholder
        self.helper = helper
        self.errorMessage = errorMessage
        self.options = options
        self.optionSelectionChanged = optionSelectionChanged
    }

    public init(
        title: String? = nil,
        placeholder: String? = nil,
        helper: String? = nil,
        errorMessage: String? = nil,
        options: [Option],
        optionSelectionChanged: ((Option?) -> Void)? = nil
    ) {
        self.title = if let title {
            ParraLabelContent(text: title)
        } else {
            nil
        }
        self.placeholder = if let placeholder {
            ParraLabelContent(text: placeholder)
        } else {
            nil
        }
        self.helper = if let helper {
            ParraLabelContent(text: helper)
        } else {
            nil
        }
        self.errorMessage = errorMessage
        self.options = options
        self.optionSelectionChanged = optionSelectionChanged
    }

    // MARK: - Public

    public struct Option: Identifiable, Hashable {
        public let id: String
        public let title: String
        public let value: String?
    }

    public let title: ParraLabelContent?
    public let placeholder: ParraLabelContent?

    /// A string which is displayed below the menu to supply suplemental
    /// information.
    public let helper: ParraLabelContent?

    /// A string which is displayed below the menu to indicate a validation
    /// error. When `errorMessage` and `helper` are both present, `errorMessage`
    /// will take precedence.
    public let errorMessage: String?

    public let options: [Option]
    public let optionSelectionChanged: ((Option?) -> Void)?
}
