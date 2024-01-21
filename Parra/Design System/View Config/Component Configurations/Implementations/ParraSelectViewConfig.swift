//
//  ParraSelectViewConfig.swift
//  Parra
//
//  Created by Mick MacCallum on 1/23/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

public struct ParraSelectViewConfig: ParraViewConfigType, ParraMergableViewConfig, Hashable {
    public let font: Font?
    public let color: Color?

    public let background: ParraBackground?
    public let cornerRadius: RectangleCornerRadii?
    public let padding: EdgeInsets?

    public func mergedConfig(
        with replacementConfig: ParraSelectViewConfig?
    ) -> ParraSelectViewConfig {
        return ParraSelectViewConfig(
            font: replacementConfig?.font ?? font,
            color: replacementConfig?.color ?? color,
            background: replacementConfig?.background ?? background,
            cornerRadius: replacementConfig?.cornerRadius ?? cornerRadius,
            padding: replacementConfig?.padding ?? padding
        )
    }
}
