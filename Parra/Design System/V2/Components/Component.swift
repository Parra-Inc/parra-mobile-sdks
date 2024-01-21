//
//  Component.swift
//  Parra
//
//  Created by Mick MacCallum on 1/28/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

internal protocol Component: View {
    associatedtype Config: ComponentConfig
    associatedtype Content: ComponentContent
    associatedtype Style: ComponentStyle

    var config: Config { get }
    var content: Content { get }
    var style: Style { get }

    init(config: Config, content: Content, style: Style)

    static func defaultStyleInContext(
        of theme: ParraTheme,
        with config: Config
    ) -> Style
}
