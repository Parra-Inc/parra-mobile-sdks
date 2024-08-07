//
//  FlexibleFrameAttributes.swift
//  Parra
//
//  Created by Mick MacCallum on 1/31/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

struct FlexibleFrameAttributes {
    // MARK: - Lifecycle

    init(
        minWidth: CGFloat? = nil,
        idealWidth: CGFloat? = nil,
        maxWidth: CGFloat? = nil,
        minHeight: CGFloat? = nil,
        idealHeight: CGFloat? = nil,
        maxHeight: CGFloat? = nil,
        alignment: Alignment = .center
    ) {
        self.minWidth = minWidth
        self.idealWidth = idealWidth
        self.maxWidth = maxWidth
        self.minHeight = minHeight
        self.idealHeight = idealHeight
        self.maxHeight = maxHeight
        self.alignment = alignment
    }

    // MARK: - Internal

    let minWidth: CGFloat?
    let idealWidth: CGFloat?
    let maxWidth: CGFloat?
    let minHeight: CGFloat?
    let idealHeight: CGFloat?
    let maxHeight: CGFloat?
    let alignment: Alignment
}

// MARK: OverridableAttributes

extension FlexibleFrameAttributes: OverridableAttributes {
    func mergingOverrides(
        _ overrides: FlexibleFrameAttributes?
    ) -> FlexibleFrameAttributes {
        return FlexibleFrameAttributes(
            minWidth: overrides?.minWidth ?? minWidth,
            idealWidth: overrides?.idealWidth ?? idealWidth,
            maxWidth: overrides?.maxWidth ?? maxWidth,
            minHeight: overrides?.minHeight ?? minHeight,
            idealHeight: overrides?.idealHeight ?? idealHeight,
            maxHeight: overrides?.maxHeight ?? maxHeight,
            alignment: overrides?.alignment ?? alignment
        )
    }
}
