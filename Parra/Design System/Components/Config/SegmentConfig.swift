//
//  SegmentConfig.swift
//  Parra
//
//  Created by Mick MacCallum on 2/29/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

public struct SegmentConfig {
    // MARK: - Lifecycle

    public init(
        optionLabels: LabelConfig = LabelConfig(fontStyle: .body)
    ) {
        self.optionLabels = optionLabels
    }

    // MARK: - Public

    public let optionLabels: LabelConfig
}
