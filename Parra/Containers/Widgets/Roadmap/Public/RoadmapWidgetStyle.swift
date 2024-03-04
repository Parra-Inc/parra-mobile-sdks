//
//  RoadmapWidgetStyle.swift
//  Parra
//
//  Created by Mick MacCallum on 3/2/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

public struct RoadmapWidgetStyle: WidgetStyle {
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
            contentPadding: EdgeInsets(vertical: 12, horizontal: 20),
            cornerRadius: .zero,
            padding: EdgeInsets(top: 16, leading: 0, bottom: 0, trailing: 0)
        )
    }
}
