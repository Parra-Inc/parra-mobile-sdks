//
//  ParraTextButtonConfig.swift
//  Parra
//
//  Created by Mick MacCallum on 1/30/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

public struct ParraTextButtonConfig: Equatable {
    // MARK: - Lifecycle

    public init(
        type: ParraButtonType = .primary,
        size: ParraButtonSize = .medium,
        isMaxWidth: Bool = false
    ) {
        self.type = type
        self.size = size
        self.isMaxWidth = isMaxWidth
    }

    // MARK: - Public

    public let type: ParraButtonType
    public let size: ParraButtonSize
    public let isMaxWidth: Bool
}
