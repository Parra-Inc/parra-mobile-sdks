//
//  TextButtonConfig.swift
//  Parra
//
//  Created by Mick MacCallum on 1/30/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

public struct TextButtonConfig: Equatable {
    // MARK: - Lifecycle

    public init(
        style: ParraButtonCategory = .primary,
        size: ParraButtonSize = .medium,
        isMaxWidth: Bool = false
    ) {
        self.style = style
        self.size = size
        self.isMaxWidth = isMaxWidth
    }

    // MARK: - Public

    public let style: ParraButtonCategory
    public let size: ParraButtonSize
    public let isMaxWidth: Bool
}
