//
//  EmptyStateComponentType.swift
//  Parra
//
//  Created by Mick MacCallum on 3/13/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

// extension EmptyStateComponentType {
//    static func applyStandardCustomizations(
//        onto inputAttributes: EmptyStateAttributes?,
//        theme: ParraTheme,
//        config: EmptyStateConfig
//    ) -> EmptyStateAttributes {
//        let base = inputAttributes ?? .init()
//
//        let defaultAttributes = EmptyStateAttributes(
//            title: LabelAttributes(
//                padding: .padding(top: 12)
//            ),
//            subtitle: LabelAttributes(
//                padding: .padding(top: 12)
//            ),
//            icon: ImageAttributes(
//                tint: theme.palette.secondary.shade400.toParraColor(),
//                padding: .padding(bottom: 24),
//                frame: .fixed(
//                    FixedFrameAttributes(width: 96)
//                )
//            ),
//            primaryAction: TextButtonAttributes(
//                padding: .padding(top: 36, bottom: 4),
//                title: LabelAttributes(
//                    frame: .flexible(.init(maxWidth: 240))
//                )
//            ),
//            secondaryAction: TextButtonAttributes(
//                title: LabelAttributes(
//                    frame: .flexible(.init(maxWidth: 240))
//                )
//            ),
//            background: theme.palette.primaryBackground,
//            padding: EdgeInsets(vertical: 20, horizontal: 36)
//        )
//
//        return base.withUpdates(
//            updates: defaultAttributes
//        )
//    }
// }
