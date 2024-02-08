//
//  TextEditorComponentType.swift
//  Parra
//
//  Created by Mick MacCallum on 2/5/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

protocol TextEditorComponentType: View {
    var config: TextEditorConfig { get }
    var content: TextEditorContent { get }
    var style: ParraAttributedTextEditorStyle { get }

    init(
        config: TextEditorConfig,
        content: TextEditorContent,
        style: ParraAttributedTextEditorStyle
    )

    static func applyStandardCustomizations(
        onto inputAttributes: TextEditorAttributes?,
        theme: ParraTheme,
        config: TextEditorConfig
    ) -> TextEditorAttributes
}
