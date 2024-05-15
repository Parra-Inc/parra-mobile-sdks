//
//  FrameAttributes.swift
//  Parra
//
//  Created by Mick MacCallum on 3/4/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Foundation

enum FrameAttributes {
    case fixed(FixedFrameAttributes)
    case flexible(FlexibleFrameAttributes)
}

// MARK: OverridableAttributes

extension FrameAttributes: OverridableAttributes {
    func mergingOverrides(
        _ overrides: FrameAttributes?
    ) -> FrameAttributes {
        guard let overrides else {
            return self
        }

        switch (self, overrides) {
        case (.fixed(let attributes), .fixed(let overrides)):
            return .fixed(attributes.mergingOverrides(overrides))
        case (.flexible(let attributes), .flexible(let overrides)):
            return .flexible(attributes.mergingOverrides(overrides))
        default:
            return overrides
        }
    }
}
