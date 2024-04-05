//
//  ComponentFactory.swift
//  Parra
//
//  Created by Mick MacCallum on 1/28/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

class ComponentFactory: ObservableObject {
    // MARK: - Lifecycle

    init(
        global: GlobalComponentAttributes?,
        theme: ParraTheme
    ) {
        self.global = global
        self.theme = theme
    }

    // MARK: - Internal

    let global: GlobalComponentAttributes?
    let theme: ParraTheme
}
