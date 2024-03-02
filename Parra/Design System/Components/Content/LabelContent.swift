//
//  LabelContent.swift
//  Parra
//
//  Created by Mick MacCallum on 1/28/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI
import UIKit

public struct LabelContent {
    // MARK: - Lifecycle

    public init(
        text: String,
        icon: UIImage? = nil
    ) {
        self.text = text
        self.icon = icon
    }

    // MARK: - Public

    public let text: String
    public let icon: UIImage?
}
