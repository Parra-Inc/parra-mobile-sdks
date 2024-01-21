//
//  GlobalComponentStylizer.swift
//  Parra
//
//  Created by Mick MacCallum on 1/28/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

/// A place to provide global defaults for basic styles of Parra components, given contextual information about
/// where they will be used.
internal class GlobalComponentStylizer {
    internal typealias ComponentStylizer<
        Config: ComponentConfig,
        Content: ComponentContent,
        Style: ComponentStyle
    > = (
        _ config: Config,
        _ content: Content,
        _ defaultStyle: Style
    ) -> Style

    internal var textStylizer: ComponentStylizer<TextConfig, TextContent, TextStyle>?

    internal var plainButtonStylizer: ComponentStylizer<ButtonConfig, ButtonContent, ButtonStyle>?
    internal var outlinedButtonStylizer: ComponentStylizer<ButtonConfig, ButtonContent, ButtonStyle>?
    internal var containedButtonStylizer: ComponentStylizer<ButtonConfig, ButtonContent, ButtonStyle>?

    internal init(
        textStylizer: ComponentStylizer<TextConfig, TextContent, TextStyle>? = nil,
        plainButtonStylizer: ComponentStylizer<ButtonConfig, ButtonContent, ButtonStyle>? = nil,
        outlinedButtonStylizer: ComponentStylizer<ButtonConfig, ButtonContent, ButtonStyle>? = nil,
        containedButtonStylizer: ComponentStylizer<ButtonConfig, ButtonContent, ButtonStyle>? = nil
    ) {
        self.textStylizer = textStylizer
        self.plainButtonStylizer = plainButtonStylizer
        self.outlinedButtonStylizer = outlinedButtonStylizer
        self.containedButtonStylizer = containedButtonStylizer
    }

    func getStylizer<
        Config: ComponentConfig,
        Content: ComponentContent,
        Style: ComponentStyle
    >(styleType: Style.Type) -> ComponentStylizer<Config, Content, Style>? {
        switch styleType {
        case is TextStyle.Type:
            return textStylizer as? ComponentStylizer<Config, Content, Style>
        case is ButtonStyle.Type:
            return plainButtonStylizer as? ComponentStylizer<Config, Content, Style>
        default:
            return nil
        }
    }
}
