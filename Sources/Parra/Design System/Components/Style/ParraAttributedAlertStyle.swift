//
//  ParraAttributedAlertStyle.swift
//  Parra
//
//  Created by Mick MacCallum on 3/7/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

struct ParraAttributedAlertStyle: ParraAttributedStyle {
    // MARK: - Lifecycle

    init(
        config: AlertConfig,
        content: AlertContent,
        attributes: AlertAttributes,
        theme: ParraTheme
    ) {
        self.config = config
        self.content = content
        self.attributes = attributes
        self.theme = theme
    }

    // MARK: - Internal

    let config: AlertConfig
    let content: AlertContent
    let attributes: AlertAttributes
    let theme: ParraTheme

    func withAttributes(
        attributes: AlertAttributes
    ) -> ParraAttributedAlertStyle {
        return ParraAttributedAlertStyle(
            config: config,
            content: content,
            attributes: attributes,
            theme: theme
        )
    }
}
