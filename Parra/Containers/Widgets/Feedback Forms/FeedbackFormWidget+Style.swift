//
//  FeedbackFormWidget+Style.swift
//  Parra
//
//  Created by Mick MacCallum on 2/24/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

extension FeedbackFormWidget {
    struct Style: WidgetStyle {
        let background: (any ShapeStyle)?
        let contentPadding: EdgeInsets
        let cornerRadius: ParraCornerRadiusSize
        let padding: EdgeInsets

        static func `default`(with theme: ParraTheme) -> FeedbackFormWidget
            .Style
        {
            let palette = theme.palette

            return Style(
                background: palette.primaryBackground,
                contentPadding: EdgeInsets(vertical: 12, horizontal: 12),
                cornerRadius: .zero,
                padding: EdgeInsets(top: 16, leading: 0, bottom: 0, trailing: 0)
            )
        }
    }
}
