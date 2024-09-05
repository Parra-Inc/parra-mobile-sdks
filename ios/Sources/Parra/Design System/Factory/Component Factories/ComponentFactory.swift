//
//  ComponentFactory.swift
//  Parra
//
//  Created by Mick MacCallum on 1/28/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

@Observable
class ComponentFactory {
    // MARK: - Lifecycle

    init(
        attributes: ComponentAttributesProvider =
            ParraGlobalComponentAttributes(),
        theme: ParraTheme
    ) {
        self.attributeProvider = attributes
        self.theme = theme
    }

    // MARK: - Internal

    let attributeProvider: ComponentAttributesProvider
    let theme: ParraTheme
}
