//
//  MenuConfig.swift
//  Parra
//
//  Created by Mick MacCallum on 2/5/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

internal struct MenuConfig {
    internal let label: LabelConfig

    internal init(
        label: LabelConfig = LabelConfig(type: .body)
    ) {
        self.label = label
    }
}
