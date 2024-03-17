//
//  RoadmapWidgetStyle.swift
//  Parra
//
//  Created by Mick MacCallum on 3/2/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

public struct RoadmapWidgetStyle: WidgetStyle {
    // MARK: - Lifecycle

    public init(
        background: (any ShapeStyle)?,
        contentPadding: EdgeInsets,
        cornerRadius: ParraCornerRadiusSize,
        padding: EdgeInsets
    ) {
        self.background = background
        self.contentPadding = contentPadding
        self.cornerRadius = cornerRadius
        self.padding = padding
    }

    // MARK: - Public

    public let background: (any ShapeStyle)?
    public let contentPadding: EdgeInsets
    public let cornerRadius: ParraCornerRadiusSize
    public let padding: EdgeInsets

    public static func `default`(
        with theme: ParraTheme
    ) -> RoadmapWidgetStyle {
        let palette = theme.palette

        return RoadmapWidgetStyle(
            background: palette.primaryBackground,
            contentPadding: .padding(vertical: 12, horizontal: 20),
            cornerRadius: .zero,
            padding: .padding(top: 16)
        )
    }
}
