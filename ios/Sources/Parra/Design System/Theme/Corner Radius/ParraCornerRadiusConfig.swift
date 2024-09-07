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
        xs: RectangleCornerRadii = ParraCornerRadiusConfig.default.xs,
        sm: RectangleCornerRadii = ParraCornerRadiusConfig.default.sm,
        md: RectangleCornerRadii = ParraCornerRadiusConfig.default.md,
        lg: RectangleCornerRadii = ParraCornerRadiusConfig.default.lg,
        xl: RectangleCornerRadii = ParraCornerRadiusConfig.default.xl,
        xxl: RectangleCornerRadii = ParraCornerRadiusConfig.default.xxl,
        xxxl: RectangleCornerRadii = ParraCornerRadiusConfig.default.xxxl,
        full: RectangleCornerRadii = ParraCornerRadiusConfig.default.full
    ) {
        self.xs = xs
        self.sm = sm
        self.md = md
        self.lg = lg
        self.xl = xl
        self.xxl = xxl
        self.xxxl = xxxl
        self.full = full
    }

    // MARK: - Public

    public static let `default` = ParraCornerRadiusConfig(
        xs: .init(allCorners: 2),
        sm: .init(allCorners: 4),
        md: .init(allCorners: 6),
        lg: .init(allCorners: 8),
        xl: .init(allCorners: 12),
        xxl: .init(allCorners: 16),
        xxxl: .init(allCorners: 24),
        full: .init(allCorners: 9_999)
    )

    public let xs: RectangleCornerRadii
    public let sm: RectangleCornerRadii
    public let md: RectangleCornerRadii
    public let lg: RectangleCornerRadii
    public let xl: RectangleCornerRadii
    public let xxl: RectangleCornerRadii
    public let xxxl: RectangleCornerRadii
    public let full: RectangleCornerRadii

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
        case .xxl:
            return xxl
        case .xxxl:
            return xxxl
        case .full:
            return full
        }
    }
}
