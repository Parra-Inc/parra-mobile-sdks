//
//  ImageButtonContent.swift
//  Parra
//
//  Created by Mick MacCallum on 3/4/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

public struct ImageButtonContent: Hashable, Equatable {
    // MARK: - Lifecycle

    public init(
        image: ImageContent,
        isDisabled: Bool = false,
        onPress: (() -> Void)? = nil
    ) {
        self.image = image
        self.isDisabled = isDisabled
        self.onPress = onPress
    }

    // MARK: - Public

    public let image: ImageContent
    public let isDisabled: Bool

    public internal(set) var onPress: (() -> Void)?

    public static func == (
        lhs: ImageButtonContent,
        rhs: ImageButtonContent
    ) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(image)
        hasher.combine(isDisabled)
    }
}
