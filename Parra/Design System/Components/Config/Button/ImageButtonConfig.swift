//
//  ImageButtonConfig.swift
//  Parra
//
//  Created by Mick MacCallum on 3/4/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

public struct ImageButtonConfig {
    // MARK: - Lifecycle

    public init(
        style: ButtonCategory = .primary,
        size: Size = .smallSquare,
        variant: ButtonVariant = .plain
    ) {
        self.style = style
        self.size = size
        self.variant = variant
    }

    // MARK: - Public

    public let style: ButtonCategory
    public let size: Size
    public let variant: ButtonVariant
}
