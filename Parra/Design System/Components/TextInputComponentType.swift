//
//  TextInputComponentType.swift
//  Parra
//
//  Created by Mick MacCallum on 2/20/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

protocol TextInputComponentType: View {
    var config: TextInputConfig { get }
    var content: TextInputContent { get }
    var style: ParraAttributedTextInputStyle { get }

    init(
        config: TextInputConfig,
        content: TextInputContent,
        style: ParraAttributedTextInputStyle
    )

    static func applyStandardCustomizations(
        onto inputAttributes: TextInputAttributes?,
        theme: ParraTheme,
        config: TextInputConfig
    ) -> TextInputAttributes
}
