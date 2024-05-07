//
//  ParraAttributes+TextEditor.swift
//  Parra
//
//  Created by Mick MacCallum on 5/7/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

public extension ParraAttributes {
    struct TextEditor {
        public internal(set) var text: ParraAttributes.Text
        public internal(set) var lineLimit: Int?

        public internal(set) var border: ParraAttributes.Border
        public internal(set) var cornerRadius: ParraCornerRadiusSize
        public internal(set) var padding: ParraPaddingSize
        public internal(set) var background: Color?
    }
}
