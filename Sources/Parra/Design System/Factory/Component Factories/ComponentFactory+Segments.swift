//
//  ComponentFactory+Segments.swift
//  Parra
//
//  Created by Mick MacCallum on 3/7/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

extension ComponentFactory {
    @ViewBuilder
    func buildSegment(
        config: SegmentConfig,
        content: SegmentContent,
        localAttributes: SegmentAttributes? = nil
    ) -> some View {
        EmptyView()
//        let mergedAttributes = SegmentComponent
//            .applyStandardCustomizations(
//                onto: localAttributes,
//                theme: theme,
//                config: config
//            )
//
//        // If a container level factory function was provided for this component,
//        // use it and supply global attribute overrides instead of local, if provided.
//        if let builder = suppliedBuilder,
//           let view = builder(config, content, mergedAttributes)
//        {
//            view
//        } else {
//            let style = ParraAttributedSegmentStyle(
//                config: config,
//                content: content,
//                attributes: mergedAttributes,
//                theme: theme
//            )
//
//            SegmentComponent(
//                config: config,
//                content: content,
//                style: style
//            )
//        }
    }
}
