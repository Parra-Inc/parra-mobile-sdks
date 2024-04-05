//
//  ParraAttributedSegmentStyle.swift
//  Parra
//
//  Created by Mick MacCallum on 2/29/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

struct ParraAttributedSegmentStyle: ParraAttributedStyle {
    // MARK: - Lifecycle

    init(
        config: SegmentConfig,
        content: SegmentContent,
        attributes: SegmentAttributes,
        theme: ParraTheme
    ) {
        self.config = config
        self.content = content
        self.attributes = attributes
        self.theme = theme
    }

    // MARK: - Internal

    let config: SegmentConfig
    let content: SegmentContent
    let attributes: SegmentAttributes
    let theme: ParraTheme

    func withAttributes(
        attributes: SegmentAttributes
    ) -> ParraAttributedSegmentStyle {
        return ParraAttributedSegmentStyle(
            config: config,
            content: content,
            attributes: attributes,
            theme: theme
        )
    }
}
