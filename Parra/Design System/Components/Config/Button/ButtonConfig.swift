//
//  ButtonConfig.swift
//  Parra
//
//  Created by Mick MacCallum on 1/30/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

public struct ButtonConfig {
    // MARK: - Lifecycle

    public init(
        style: ButtonCategory = .primary,
        size: ButtonSize = .medium,
        isMaxWidth: Bool = false
    ) {
        self.style = style
        self.size = size
        self.isMaxWidth = isMaxWidth
    }

    // MARK: - Public

    public let style: ButtonCategory
    public let size: ButtonSize
    public let isMaxWidth: Bool
}
