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

    init(
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
}
