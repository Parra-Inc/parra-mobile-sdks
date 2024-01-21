//
//  ParraTextInputViewConfig.swift
//  Parra
//
//  Created by Mick MacCallum on 1/23/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI
import UIKit

public struct ParraTextInputViewConfig: ParraViewConfigType, ParraMergableViewConfig, Hashable {
    public let font: Font?
    public let color: Color?

    public let background: ParraBackground?
    public let cornerRadius: RectangleCornerRadii?
    public let padding: EdgeInsets?

    public func mergedConfig(
        with replacementConfig: ParraTextInputViewConfig?
    ) -> ParraTextInputViewConfig {
        return ParraTextInputViewConfig(
            font: replacementConfig?.font ?? font,
            color: replacementConfig?.color ?? color,
            background: replacementConfig?.background ?? background,
            cornerRadius: replacementConfig?.cornerRadius ?? cornerRadius,
            padding: replacementConfig?.padding ?? padding
        )
    }
}
