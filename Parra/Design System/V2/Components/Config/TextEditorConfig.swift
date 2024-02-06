//
//  TextEditorConfig.swift
//  Parra
//
//  Created by Mick MacCallum on 2/5/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

internal struct TextEditorConfig {
    internal let minLines: Int
    internal let minCharacters: Int
    internal let maxCharacters: Int?
    internal let maxHeight: Int?

    /// Whether or not to show the status label that displays characters remaining/etc.
    internal let showStatusLabel: Bool

    internal init(
        minLines: Int = 3,
        minCharacters: Int = 0,
        maxCharacters: Int?,
        maxHeight: Int? = 240,
        showStatusLabel: Bool = true
    ) {
        self.minLines = minLines
        self.minCharacters = minCharacters
        self.maxCharacters = maxCharacters
        self.maxHeight = maxHeight
        self.showStatusLabel = showStatusLabel
    }
}
