//
//  FeedbackCardWidget+Style.swift
//  Parra
//
//  Created by Mick MacCallum on 2/24/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

extension FeedbackCardWidget {
    struct Style: WidgetStyle {
        let background: (any ShapeStyle)?
        let contentPadding: EdgeInsets
        let cornerRadius: ParraCornerRadiusSize
        let padding: EdgeInsets

        static func `default`(with theme: ParraTheme) -> FeedbackCardWidget
            .Style
        {
            let palette = theme.palette

            return Style(
                background: palette.primaryBackground,
                contentPadding: EdgeInsets(20),
                cornerRadius: ParraCornerRadiusSize.large,
                padding: .zero
            )
        }
    }
}
