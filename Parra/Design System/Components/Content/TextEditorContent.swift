//
//  TextEditorContent.swift
//  Parra
//
//  Created by Mick MacCallum on 2/5/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

public struct TextEditorContent {
    // MARK: - Lifecycle

    init(
        title: LabelContent? = nil,
        placeholder: LabelContent? = nil,
        helper: LabelContent? = nil,
        errorMessage: String? = nil,
        textChanged: ((String?) -> Void)? = nil
    ) {
        self.title = title
        self.placeholder = placeholder
        self.helper = helper
        self.errorMessage = errorMessage
        self.textChanged = textChanged
    }

    init(
        title: String? = nil,
        placeholder: String? = nil,
        helper: String? = nil,
        errorMessage: String? = nil,
        textChanged: ((String?) -> Void)? = nil
    ) {
        self.title = if let title {
            LabelContent(text: title)
        } else {
            nil
        }

        self.placeholder = if let placeholder {
            LabelContent(text: placeholder)
        } else {
            nil
        }

        self.helper = if let helper {
            LabelContent(text: helper)
        } else {
            nil
        }

        self.errorMessage = errorMessage
        self.textChanged = textChanged
    }

    // MARK: - Public

    /// A string which is displayed in a label above the text editor to provide contextual information.
    public let title: LabelContent?

    /// A string which is displayed inside the text editor whenever the input string is empty.
    public let placeholder: LabelContent?

    /// A string which is displayed below the text editor to supply suplemental information. In the default
    /// implementation, helper text and error message are displayed using the same label, and ``errorMessage``
    /// takes precedance over ``helper``.
    public let helper: LabelContent?
    public let errorMessage: String?
    public let textChanged: ((String?) -> Void)?
}
