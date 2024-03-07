//
//  ParraCornerRadiusConfig.swift
//  Parra
//
//  Created by Mick MacCallum on 1/20/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

public struct ParraCornerRadiusConfig {
    // MARK: - Lifecycle

    public init(
        extraSmall: RectangleCornerRadii,
        small: RectangleCornerRadii,
        medium: RectangleCornerRadii,
        large: RectangleCornerRadii,
        extraLarge: RectangleCornerRadii
    ) {
        self.xs = extraSmall
        self.sm = small
        self.md = medium
        self.lg = large
        self.xl = extraLarge
    }

    // MARK: - Public

    public static let `default` = ParraCornerRadiusConfig(
        extraSmall: .init(allCorners: 4),
        small: .init(allCorners: 6),
        medium: .init(allCorners: 8),
        large: .init(allCorners: 12),
        extraLarge: .init(allCorners: 16)
    )

    public let xs: RectangleCornerRadii
    public let sm: RectangleCornerRadii
    public let md: RectangleCornerRadii
    public let lg: RectangleCornerRadii
    public let xl: RectangleCornerRadii

    public func value(
        for size: ParraCornerRadiusSize?
    ) -> RectangleCornerRadii {
        guard let size else {
            return .zero
        }

        switch size {
        case .zero:
            return .zero
        case .xs:
            return xs
        case .sm:
            return sm
        case .md:
            return md
        case .lg:
            return lg
        case .xl:
            return xl
        }
    }
}
