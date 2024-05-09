//
//  ParraAttributes+TextEditor.swift
//  Parra
//
//  Created by Mick MacCallum on 5/7/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

// MARK: - ParraAttributes.TextEditor

public extension ParraAttributes {
    struct TextEditor {
        public internal(set) var text: ParraAttributes.Text
        public internal(set) var lineLimit: Int?

        public internal(set) var border: ParraAttributes.Border
        public internal(set) var cornerRadius: ParraCornerRadiusSize?
        public internal(set) var padding: ParraPaddingSize?
        public internal(set) var background: Color?
    }
}

// MARK: - ParraAttributes.TextEditor + OverridableAttributes

extension ParraAttributes.TextEditor: OverridableAttributes {
    func mergingOverrides(
        _ overrides: ParraAttributes.TextEditor?
    ) -> ParraAttributes.TextEditor {
        return ParraAttributes.TextEditor(
            text: text.mergingOverrides(overrides?.text),
            lineLimit: overrides?.lineLimit ?? lineLimit,
            border: border.mergingOverrides(overrides?.border),
            cornerRadius: overrides?.cornerRadius ?? cornerRadius,
            padding: overrides?.padding ?? padding,
            background: overrides?.background ?? background
        )
    }
}
