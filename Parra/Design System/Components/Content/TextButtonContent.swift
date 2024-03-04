//
//  TextButtonContent.swift
//  Parra
//
//  Created by Mick MacCallum on 1/28/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

public struct TextButtonContent {
    // MARK: - Lifecycle

    public init(
        text: LabelContent,
        isDisabled: Bool = false,
        onPress: (() -> Void)? = nil
    ) {
        self.text = text
        self.isDisabled = isDisabled
        self.onPress = onPress
    }

    // MARK: - Public

    public let text: LabelContent
    public let isDisabled: Bool

    public internal(set) var onPress: (() -> Void)?
}
