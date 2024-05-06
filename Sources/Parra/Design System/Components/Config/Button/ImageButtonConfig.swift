//
//  ImageButtonConfig.swift
//  Parra
//
//  Created by Mick MacCallum on 3/4/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

public struct ImageButtonConfig: Equatable {
    // MARK: - Lifecycle

    public init(
        style: ParraButtonType = .primary,
        size: Size = .smallSquare,
        variant: ParraButtonVariant = .plain
    ) {
        self.style = style
        self.size = size
        self.variant = variant
    }

    // MARK: - Public

    public let style: ParraButtonType
    public let size: Size
    public let variant: ParraButtonVariant
}
