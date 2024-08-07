//
//  MenuConfig.swift
//  Parra
//
//  Created by Mick MacCallum on 2/5/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

public struct ParraMenuConfig {
    // MARK: - Lifecycle

    public init(
        sortOrder: MenuOrder = .fixed
    ) {
        self.sortOrder = sortOrder
    }

    // MARK: - Public

    public let sortOrder: MenuOrder

    // MARK: - Internal

    func withFormTextFieldData(_ data: ParraFeedbackFormSelectFieldData)
        -> ParraMenuConfig
    {
        // There are currently no fields used in config from this data object
        // but this keeps with a pattern used for other field types.
        self
    }
}
