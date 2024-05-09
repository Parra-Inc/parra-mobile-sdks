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
        type: ParraButtonType = .primary,
        size: ParraImageButtonSize = .smallSquare,
        variant: ParraButtonVariant = .plain
    ) {
        self.type = type
        self.size = size
        self.variant = variant
    }

    // MARK: - Public

    public let type: ParraButtonType
    public let size: ParraImageButtonSize
    public let variant: ParraButtonVariant
}
