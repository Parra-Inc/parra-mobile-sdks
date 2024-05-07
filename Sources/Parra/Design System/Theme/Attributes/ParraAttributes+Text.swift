//
//  ParraAttributes+Text.swift
//  Parra
//
//  Created by Mick MacCallum on 5/2/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

public extension ParraAttributes {
    /// Attributes specific to text, not necessarily a "label" component.
    struct Text {
        // MARK: - Lifecycle

        public init(
            font: Font? = nil,
            width: Font.Width? = nil,
            weight: Font.Weight? = nil,
            design: Font.Design? = nil,
            color: Color? = nil,
            alignment: TextAlignment? = nil,
            shadow: Shadow? = nil
        ) {
            self.font = font
            self.width = width
            self.weight = weight
            self.design = design
            self.color = color
            self.alignment = alignment
            self.shadow = shadow
        }

        public init(
            font: UIFont? = nil,
            width: Font.Width? = nil,
            weight: Font.Weight? = nil,
            design: Font.Design? = nil,
            color: Color? = nil,
            alignment: TextAlignment? = nil,
            shadow: Shadow? = nil
        ) {
            self.font = if let font {
                Font(font as CTFont)
            } else {
                nil
            }

            self.width = width
            self.weight = weight
            self.design = design
            self.color = color
            self.alignment = alignment
            self.shadow = shadow
        }

        // MARK: - Public

        public var font: Font?
        public var width: Font.Width?
        public var weight: Font.Weight?
        public var design: Font.Design?
        public var color: Color?
        public var alignment: TextAlignment?
        public var shadow: Shadow?
    }
}
