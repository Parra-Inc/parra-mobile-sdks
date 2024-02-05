//
//  GlobalComponentStylizer.swift
//  Parra
//
//  Created by Mick MacCallum on 1/28/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

/// A place to provide global defaults for basic styles of Parra components, given contextual information about
/// where they will be used.
internal class GlobalComponentAttributes {
    internal typealias LabelAttributeFactory = (
        _ config: LabelConfig,
        _ content: LabelContent,
        _ defaultAttributes: LabelAttributes?
    ) -> LabelAttributes

    internal typealias ButtonAttributeFactory = (
        _ config: ButtonConfig,
        _ content: ButtonContent,
        _ defaultAttributes: ButtonAttributes?
    ) -> ButtonAttributes

    internal private(set) var labelAttributeFactory: LabelAttributeFactory?
    internal private(set) var buttonAttributeFactory: ButtonAttributeFactory?

    internal init(
        labelAttributeFactory: LabelAttributeFactory? = nil,
        buttonAttributeFactory: ButtonAttributeFactory? = nil
    ) {
        self.labelAttributeFactory = labelAttributeFactory
        self.buttonAttributeFactory = buttonAttributeFactory
    }
}
