//
//  ParraPaddingConfig.swift
//  Parra
//
//  Created by Mick MacCallum on 5/2/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

public struct ParraPaddingConfig {
    // MARK: - Lifecycle

    public init(
        xs: EdgeInsets,
        sm: EdgeInsets,
        md: EdgeInsets,
        lg: EdgeInsets,
        xl: EdgeInsets,
        xxl: EdgeInsets,
        xxxl: EdgeInsets
    ) {
        self.xs = xs
        self.sm = sm
        self.md = md
        self.lg = lg
        self.xl = xl
        self.xxl = xxl
        self.xxxl = xxxl
    }

    // MARK: - Public

    public static let `default` = ParraPaddingConfig(
        xs: EdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2),
        sm: EdgeInsets(top: 4, leading: 4, bottom: 4, trailing: 4),
        md: EdgeInsets(top: 6, leading: 6, bottom: 6, trailing: 6),
        lg: EdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8),
        xl: EdgeInsets(top: 12, leading: 12, bottom: 12, trailing: 12),
        xxl: EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16),
        xxxl: EdgeInsets(top: 24, leading: 24, bottom: 24, trailing: 24)
    )

    public let xs: EdgeInsets
    public let sm: EdgeInsets
    public let md: EdgeInsets
    public let lg: EdgeInsets
    public let xl: EdgeInsets
    public let xxl: EdgeInsets
    public let xxxl: EdgeInsets

    public func value(
        for size: ParraPaddingSize?
    ) -> EdgeInsets {
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
        case .custom(let value):
            return value
        }
    }
}
