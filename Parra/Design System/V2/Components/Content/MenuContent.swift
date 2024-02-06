//
//  MenuContent.swift
//  Parra
//
//  Created by Mick MacCallum on 2/5/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

internal struct MenuContent {
    internal let label: LabelContent
    internal let options: [MenuComponent.Option]
    internal let optionSelectionChanged: ((MenuComponent.Option?) -> Void)?

    internal init(
        label: LabelContent,
        options: [MenuComponent.Option],
        optionSelectionChanged: ((MenuComponent.Option?) -> Void)? = nil
    ) {
        self.label = label
        self.options = options
        self.optionSelectionChanged = optionSelectionChanged
    }

    internal func withSelection(of option: MenuComponent.Option?) -> MenuContent {
        let labelContent = if let option {
            LabelContent(text: option.title)
        } else {
            label
        }

        return MenuContent(
            label: labelContent,
            options: options,
            optionSelectionChanged: optionSelectionChanged
        )
    }
}
