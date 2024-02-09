//
//  LabelComponentType.swift
//  Parra
//
//  Created by Mick MacCallum on 1/28/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

protocol LabelComponentType: View {
    // There is a notable exception made for labels in that they do not take a config
    // object as input. There is no data in their config that is relevant to them.
    // wrapper classes utilize their config to customize their style, which they render.

    var content: LabelContent { get }
    var style: ParraAttributedLabelStyle { get }

    init(
        content: LabelContent,
        style: ParraAttributedLabelStyle
    )

    static func applyStandardCustomizations(
        onto inputAttributes: LabelAttributes?,
        theme: ParraTheme,
        config: LabelConfig
    ) -> LabelAttributes
}
