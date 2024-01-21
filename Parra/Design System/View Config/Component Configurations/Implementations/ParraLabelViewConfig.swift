//
//  ParraLabelViewConfig.swift
//  Parra
//
//  Created by Mick MacCallum on 1/22/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

public struct ParraLabelViewConfig: ParraViewConfigType, ParraMergableViewConfig, Hashable {
    public var font: Font?
    public var color: Color?

    public var background: ParraBackground?
    public var cornerRadius: RectangleCornerRadii?
    public var padding: EdgeInsets?

    public func mergedConfig(
        with replacementConfig: ParraLabelViewConfig?
    ) -> ParraLabelViewConfig {
        return ParraLabelViewConfig(
            font: replacementConfig?.font ?? font,
            color: replacementConfig?.color ?? color,
            background: replacementConfig?.background ?? background,
            cornerRadius: replacementConfig?.cornerRadius ?? cornerRadius,
            padding: replacementConfig?.padding ?? padding
        )
    }
}
