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
    ) -> some View {
        let attributes = attributeProvider.segmentedControlAttributes(
            localAttributes: localAttributes,
            theme: theme
        )

        SegmentComponent(
            config: config,
            content: content,
            attributes: attributes
        )
    }
}
