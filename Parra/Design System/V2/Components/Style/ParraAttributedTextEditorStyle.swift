//
//  ParraAttributedTextEditorStyle.swift
//  Parra
//
//  Created by Mick MacCallum on 2/5/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

struct ParraAttributedTextEditorStyle: TextEditorStyle, ParraAttributedStyle {
    let config: TextEditorConfig
    let content: TextEditorContent
    let attributes: TextEditorAttributes
    let theme: ParraTheme

    @ViewBuilder
    func makeBody(configuration: Configuration) -> some View {
        EmptyView()
    }
}
