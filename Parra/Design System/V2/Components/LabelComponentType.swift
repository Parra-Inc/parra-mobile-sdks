//
//  Component.swift
//  Parra
//
//  Created by Mick MacCallum on 1/28/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

internal protocol LabelComponentType: View {
    var config: LabelConfig { get }
    var content: LabelContent { get }
    var style: ParraAttributedLabelStyle { get }

    init(
        config: LabelConfig,
        content: LabelContent,
        style: ParraAttributedLabelStyle
    )

    static func applyStandardCustomizations(
        onto inputAttributes: LabelAttributes?,
        theme: ParraTheme,
        config: LabelConfig
    ) -> LabelAttributes
}
