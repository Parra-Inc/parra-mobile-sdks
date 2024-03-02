//
//  LabelConfig.swift
//  Parra
//
//  Created by Mick MacCallum on 1/28/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

public struct LabelConfig {
    // MARK: - Lifecycle

    public init(fontStyle: Font.TextStyle) {
        self.fontStyle = fontStyle
    }

    // MARK: - Public

    public let fontStyle: Font.TextStyle
}
