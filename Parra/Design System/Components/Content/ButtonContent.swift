//
//  ButtonContent.swift
//  Parra
//
//  Created by Mick MacCallum on 1/28/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI
import UIKit

public struct ButtonContent {
    // MARK: - Lifecycle

    init(
        type: ContentType,
        isDisabled: Bool = false,
        onPress: (() -> Void)? = nil
    ) {
        self.type = type
        self.isDisabled = isDisabled
        self.onPress = onPress
    }

    // MARK: - Public

    public enum ContentType {
        case text(LabelContent)
        case image(ImageContent)
    }

    public let type: ContentType
    public let isDisabled: Bool

    public internal(set) var onPress: (() -> Void)?
}
