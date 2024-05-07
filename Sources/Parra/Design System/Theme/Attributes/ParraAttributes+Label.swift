//
//  ParraAttributes+Label.swift
//  Parra
//
//  Created by Mick MacCallum on 5/7/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

public extension ParraAttributes {
    struct Label {
        // MARK: - Lifecycle

        public init(
            text: ParraAttributes.Text,
            icon: ParraAttributes.Image = .init(),
            border: ParraAttributes.Border = .init(),
            cornerRadius: ParraCornerRadiusSize = .zero,
            padding: ParraPaddingSize = .zero,
            background: Color? = nil
        ) {
            self.text = text
            self.icon = icon
            self.border = border
            self.cornerRadius = cornerRadius
            self.padding = padding
            self.background = background
        }

        init(
            text: ParraAttributes.Text,
            icon: ParraAttributes.Image = .init(),
            border: ParraAttributes.Border = .init(),
            cornerRadius: ParraCornerRadiusSize = .zero,
            padding: ParraPaddingSize = .zero,
            background: Color? = nil,
            frame: FrameAttributes? = nil
        ) {
            self.text = text
            self.icon = icon
            self.border = border
            self.cornerRadius = cornerRadius
            self.padding = padding
            self.background = background
            self.frame = frame
        }

        // MARK: - Public

        public internal(set) var text: ParraAttributes.Text
        public internal(set) var icon: ParraAttributes.Image
        public internal(set) var border: ParraAttributes.Border
        public internal(set) var cornerRadius: ParraCornerRadiusSize
        public internal(set) var padding: ParraPaddingSize
        public internal(set) var background: Color?

        // MARK: - Internal

        var frame: FrameAttributes?
    }
}
