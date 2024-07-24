//
//  FixedFrameAttributes.swift
//  Parra
//
//  Created by Mick MacCallum on 3/4/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

struct FixedFrameAttributes {
    // MARK: - Lifecycle

    init(
        width: CGFloat? = nil,
        height: CGFloat? = nil,
        alignment: Alignment = .center
    ) {
        self.width = width
        self.height = height
        self.alignment = alignment
    }

    // MARK: - Internal

    let width: CGFloat?
    let height: CGFloat?
    let alignment: Alignment
}

// MARK: OverridableAttributes

extension FixedFrameAttributes: OverridableAttributes {
    func mergingOverrides(
        _ overrides: FixedFrameAttributes?
    ) -> FixedFrameAttributes {
        return FixedFrameAttributes(
            width: overrides?.width ?? width,
            height: overrides?.height ?? height,
            alignment: overrides?.alignment ?? alignment
        )
    }
}
