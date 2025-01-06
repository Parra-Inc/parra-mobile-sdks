//
//  ParraTextEditorContent.swift
//  Parra
//
//  Created by Mick MacCallum on 2/5/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

public struct ParraTextEditorContent {
    // MARK: - Lifecycle

    public init(
        title: ParraLabelContent? = nil,
        defaultText: String? = nil,
        placeholder: ParraLabelContent? = nil,
        helper: ParraLabelContent? = nil,
        errorMessage: String? = nil,
        textChanged: ((String?) -> Void)? = nil
    ) {
        self.title = title
        self.defaultText = defaultText ?? ""
        self.placeholder = placeholder
        self.helper = helper
        self.errorMessage = errorMessage
        self.textChanged = textChanged
    }

    public init(
        title: String? = nil,
        defaultText: String? = nil,
        placeholder: String? = nil,
        helper: String? = nil,
        errorMessage: String? = nil,
        textChanged: ((String?) -> Void)? = nil
    ) {
        self.title = if let title {
            ParraLabelContent(text: title)
        } else {
            nil
        }

        self.defaultText = defaultText ?? ""

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
        self.textChanged = textChanged
    }

    // MARK: - Public

    /// A string which is displayed in a label above the text editor to provide
    /// contextual information.
    public let title: ParraLabelContent?

    /// A string which is displayed inside the text editor whenever the input
    /// string is empty.
    public let placeholder: ParraLabelContent?

    /// Text that should be placed in the text field when it is first displayed.
    public let defaultText: String

    /// A string which is displayed below the text editor to supply suplemental
    /// information. In the default implementation, helper text and error
    /// message are displayed using the same label, and ``errorMessage`` takes
    /// precedance over ``helper``.
    public let helper: ParraLabelContent?
    public let errorMessage: String?
    public let textChanged: ((String?) -> Void)?
}
