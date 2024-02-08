//
//  MenuContent.swift
//  Parra
//
//  Created by Mick MacCallum on 2/5/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

public struct MenuContent {
    public struct Option: Identifiable, Hashable {
        public let id: String
        public let title: String
        public let value: String?
    }

    public let title: LabelContent?
    public let placeholder: LabelContent?

    /// A string which is displayed below the menu to supply suplemental information.
    public let helper: LabelContent?

    public let options: [Option]
    public let optionSelectionChanged: ((Option?) -> Void)?

    internal init(
        title: LabelContent? = nil,
        placeholder: LabelContent? = nil,
        helper: LabelContent? = nil,
        options: [Option],
        optionSelectionChanged: ((Option?) -> Void)? = nil
    ) {
        self.title = title
        self.placeholder = placeholder
        self.helper = helper
        self.options = options
        self.optionSelectionChanged = optionSelectionChanged
    }

    internal init(
        title: String? = nil,
        placeholder: String? = nil,
        helper: String? = nil,
        options: [Option],
        optionSelectionChanged: ((Option?) -> Void)? = nil
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
        self.options = options
        self.optionSelectionChanged = optionSelectionChanged
    }
}
