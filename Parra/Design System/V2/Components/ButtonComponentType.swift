//
//  ButtonComponentType.swift
//  Parra
//
//  Created by Mick MacCallum on 2/4/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

protocol ButtonComponentType: View {
    var config: ButtonConfig { get }
    var content: ButtonContent { get }
    var style: ParraAttributedButtonStyle { get }

    init(
        config: ButtonConfig,
        content: ButtonContent,
        style: ParraAttributedButtonStyle
    )

    static func applyStandardCustomizations(
        onto inputAttributes: ButtonAttributes?,
        theme: ParraTheme,
        config: ButtonConfig
    ) -> ButtonAttributes
}
