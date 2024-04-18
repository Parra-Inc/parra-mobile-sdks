//
//  MenuConfig.swift
//  Parra
//
//  Created by Mick MacCallum on 2/5/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

public struct MenuConfig {
    // MARK: - Lifecycle

    public init(
        title: LabelConfig = LabelConfig(fontStyle: .body),
        helper: LabelConfig = LabelConfig(fontStyle: .subheadline),
        menuOption: LabelConfig = LabelConfig(fontStyle: .body),
        menuOptionSelected: LabelConfig = LabelConfig(fontStyle: .body)
    ) {
        self.title = title
        self.helper = helper
        self.menuOption = menuOption
        self.menuOptionSelected = menuOptionSelected
    }

    // MARK: - Public

    public let title: LabelConfig
    public let helper: LabelConfig
    public let menuOption: LabelConfig
    public let menuOptionSelected: LabelConfig

    // MARK: - Internal

    func withFormTextFieldData(_ data: FeedbackFormSelectFieldData)
        -> MenuConfig
    {
        // There are currently no fields used in config from this data object
        // but this keeps with a pattern used for other field types.
        self
    }
}
