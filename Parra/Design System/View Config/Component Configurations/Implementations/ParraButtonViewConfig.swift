//
//  ParraButtonViewConfig.swift
//  Parra
//
//  Created by Mick MacCallum on 1/22/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

public struct ParraButtonViewConfig: ParraViewConfigType, ParraMergableViewConfig, Hashable {
    public let title: ParraLabelViewConfig?
    public let titlePressed: ParraLabelViewConfig?
    public let titleDisabled: ParraLabelViewConfig?

    public let background: ParraBackground?
    public let cornerRadius: RectangleCornerRadii?
    public let padding: EdgeInsets?

    public func mergedConfig(
        with replacementConfig: ParraButtonViewConfig?
    ) -> ParraButtonViewConfig {
        return ParraButtonViewConfig(
            title: replacementConfig?.title ?? title,
            titlePressed: replacementConfig?.titlePressed ?? titlePressed,
            titleDisabled: replacementConfig?.titlePressed ?? titleDisabled,
            background: replacementConfig?.background ?? background,
            cornerRadius: replacementConfig?.cornerRadius ?? cornerRadius,
            padding: replacementConfig?.padding ?? padding
        )
    }

    internal func titleConfig(for state: ParraButtonState) -> ParraLabelViewConfig? {
        switch state {
        case .normal:
            return title
        case .pressed:
            return titlePressed
        case .disabled:
            return titleDisabled
        }
    }
}
