//
//  ButtonConfig.swift
//  Parra
//
//  Created by Mick MacCallum on 1/30/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

internal struct ButtonConfig: ComponentConfig {
    internal var style: ParraButtonStyle
    internal var size: ParraButtonSize
    internal var isMaxWidth: Bool
    internal var title: TextConfig

    internal init(
        style: ParraButtonStyle = .primary,
        size: ParraButtonSize = .medium,
        isMaxWidth: Bool = false,
        title: TextConfig = .init()
    ) {
        self.style = style
        self.size = size
        self.isMaxWidth = isMaxWidth
        self.title = title
    }
}
