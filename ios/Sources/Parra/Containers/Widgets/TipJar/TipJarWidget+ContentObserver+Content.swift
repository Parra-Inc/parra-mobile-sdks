//
//  TipJarWidget+ContentObserver+Content.swift
//  Parra
//
//  Created by Mick MacCallum on 11/15/24.
//

import SwiftUI

extension TipJarWidget.ContentObserver {
    struct Content: ParraContainerContent {
        // MARK: - Lifecycle

        init(
            config: ParraTipJarConfig
        ) {
            self.title = ParraLabelContent(
                text: config.defaultTitle
            )

            self.subtitle = ParraLabelContent(
                text: config.defaultSubtitle
            )

            self.image = if let defaultImage = config.defaultImage {
                .image(defaultImage, .original)
            } else {
                nil
            }
        }

        // MARK: - Internal

        let title: ParraLabelContent
        let subtitle: ParraLabelContent
        let image: ParraImageContent?
    }
}
