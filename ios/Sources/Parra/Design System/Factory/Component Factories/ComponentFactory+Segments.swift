//
//  ComponentFactory+Segments.swift
//  Parra
//
//  Created by Mick MacCallum on 3/7/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

public extension ParraComponentFactory {
    @ViewBuilder
    func buildSegment(
        config: ParraSegmentConfig,
        content: ParraSegmentContent,
        localAttributes: ParraAttributes.Segment? = nil
    ) -> ParraSegmentComponent {
        let attributes = attributeProvider.segmentedControlAttributes(
            localAttributes: localAttributes,
            theme: theme
        )

        return ParraSegmentComponent(
            config: config,
            content: content,
            attributes: attributes
        )
    }
}
