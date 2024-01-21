//
//  FeedbackFormWidgetComponentFactory.swift
//  Parra
//
//  Created by Mick MacCallum on 1/28/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

final class FeedbackFormWidgetComponentFactory: ParraComponentFactory {

    let title: ComponentBuilder.Factory<Text, TextConfig, TextContent, TextStyle>?
    let description: ComponentBuilder.Factory<Text, TextConfig, TextContent, TextStyle>?
    let submitButton: ComponentBuilder.Factory<Button<Text>, ButtonConfig, ButtonContent, ButtonStyle>?

    init(
        titleBuilder: ComponentBuilder.Factory<Text, TextConfig, TextContent, TextStyle>? = nil,
        descriptionBuilder: ComponentBuilder.Factory<Text, TextConfig, TextContent, TextStyle>? = nil,
        submitButtonBuilder: ComponentBuilder.Factory<Button<Text>, ButtonConfig, ButtonContent, ButtonStyle>? = nil
    ) {
        self.title = titleBuilder
        self.description = descriptionBuilder
        self.submitButton = submitButtonBuilder
    }
}
