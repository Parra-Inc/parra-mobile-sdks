//
//  ParraViewConfig.swift
//  Parra
//
//  Created by Mick MacCallum on 1/23/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

public struct ParraViewConfig: ParraViewConfigType, Hashable {
    public var background: ParraBackground?
    public var cornerRadius: RectangleCornerRadii?
    public var padding: EdgeInsets?

    public func mergedConfig(
        with replacementConfig: ParraViewConfig?
    ) -> ParraViewConfig {
        return ParraViewConfig(
            background: replacementConfig?.background ?? background,
            cornerRadius: replacementConfig?.cornerRadius ?? cornerRadius,
            padding: replacementConfig?.padding ?? padding
        )
    }
}
