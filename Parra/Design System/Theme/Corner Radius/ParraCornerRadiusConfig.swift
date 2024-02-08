//
//  ParraCornerRadiusConfig.swift
//  Parra
//
//  Created by Mick MacCallum on 1/20/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

public struct ParraCornerRadiusConfig {
    public static let `default` = ParraCornerRadiusConfig(
        extraSmall: .init(allCorners: 4),
        small: .init(allCorners: 6),
        medium: .init(allCorners: 8),
        large: .init(allCorners: 12),
        extraLarge: .init(allCorners: 16)
    )

    public let extraSmall: RectangleCornerRadii
    public let small: RectangleCornerRadii
    public let medium: RectangleCornerRadii
    public let large: RectangleCornerRadii
    public let extraLarge: RectangleCornerRadii

    public init(
        extraSmall: RectangleCornerRadii,
        small: RectangleCornerRadii,
        medium: RectangleCornerRadii,
        large: RectangleCornerRadii,
        extraLarge: RectangleCornerRadii
    ) {
        self.extraSmall = extraSmall
        self.small = small
        self.medium = medium
        self.large = large
        self.extraLarge = extraLarge
    }

    public func value(for size: ParraCornerRadiusSize?) -> RectangleCornerRadii {
        guard let size else {
            return .zero
        }
        
        switch size {
        case .zero:
            return .zero
        case .extraSmall:
            return extraSmall
        case .small:
            return small
        case .medium:
            return medium
        case .large:
            return large
        case .extraLarge:
            return extraLarge
        }
    }
}
