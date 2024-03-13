//
//  TextButtonContent.swift
//  Parra
//
//  Created by Mick MacCallum on 1/28/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

public struct TextButtonContent: Equatable, Hashable {
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

    public static func == (
        lhs: TextButtonContent,
        rhs: TextButtonContent
    ) -> Bool {
        return lhs.isDisabled == rhs.isDisabled && lhs.text == rhs.text
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(text)
        hasher.combine(isDisabled)
    }
}
