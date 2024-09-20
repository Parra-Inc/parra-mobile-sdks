//
//  Parra+Theme.swift
//  Parra
//
//  Created by Mick MacCallum on 4/23/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

public extension Parra {
    // MARK: - Theme

    @MainActor
    func updateTheme(to newTheme: ParraTheme) {
        let oldTheme = parraInternal.configuration.theme
        parraInternal.configuration.theme = newTheme

        parraInternal.globalComponentFactory = ParraComponentFactory(
            attributes: parraInternal.configuration.globalComponentAttributes,
            theme: newTheme
        )

        parraInternal.notificationCenter.post(
            name: Parra.themeWillChangeNotification,
            object: nil,
            userInfo: [
                "oldTheme": oldTheme,
                "newTheme": newTheme
            ]
        )
    }
}
