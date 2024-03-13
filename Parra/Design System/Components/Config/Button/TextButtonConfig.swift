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
        style: ButtonCategory = .primary,
        size: Size = .medium,
        isMaxWidth: Bool = false
    ) {
        self.style = style
        self.size = size
        self.isMaxWidth = isMaxWidth
    }

    // MARK: - Public

    public let style: ButtonCategory
    public let size: Size
    public let isMaxWidth: Bool
}
