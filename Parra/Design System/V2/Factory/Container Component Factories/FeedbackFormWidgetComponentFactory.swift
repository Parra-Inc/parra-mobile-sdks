//
//  FeedbackFormWidgetComponentFactory.swift
//  Parra
//
//  Created by Mick MacCallum on 1/28/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

final class FeedbackFormWidgetComponentFactory: ParraComponentFactory {
    let title: ComponentBuilder.Factory<Text, LabelConfig, LabelContent, LabelAttributes>?
    let description: ComponentBuilder.Factory<Text, LabelConfig, LabelContent, LabelAttributes>?
    let submitButton: ComponentBuilder.Factory<Button<Text>, ButtonConfig, ButtonContent, ButtonAttributes>?

    init(
        titleBuilder: ComponentBuilder.Factory<Text, LabelConfig, LabelContent, LabelAttributes>? = nil,
        descriptionBuilder: ComponentBuilder.Factory<Text, LabelConfig, LabelContent, LabelAttributes>? = nil,
        submitButtonBuilder: ComponentBuilder.Factory<Button<Text>, ButtonConfig, ButtonContent, ButtonAttributes>? = nil
    ) {
        self.title = titleBuilder
        self.description = descriptionBuilder
        self.submitButton = submitButtonBuilder
    }
}
