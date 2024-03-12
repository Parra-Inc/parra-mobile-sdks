//
//  ImageAttributes+BadgeDefaults.swift
//  Parra
//
//  Created by Mick MacCallum on 3/12/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

extension ImageAttributes {
    static func defaultForBadge(
        with size: Badge.Size
    ) -> ImageAttributes {
        return ImageAttributes(
            frame: .fixed(
                FixedFrameAttributes(
                    width: size.padding.leading,
                    height: size.padding.leading
                )
            )
        )
    }

    static func defaultForTintedBadge(
        with size: Badge.Size,
        tintColor: Color
    ) -> ImageAttributes {
        return defaultForBadge(with: size).withUpdates(
            updates: ImageAttributes(tint: tintColor)
        )
    }
}
