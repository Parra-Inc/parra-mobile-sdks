//
//  FeedbackFormWidgetStyle.swift
//  Parra
//
//  Created by Mick MacCallum on 2/24/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

public struct FeedbackFormWidgetStyle: WidgetStyle {
    public let background: (any ShapeStyle)?
    public let contentPadding: EdgeInsets
    public let cornerRadius: ParraCornerRadiusSize
    public let padding: EdgeInsets

    public static func `default`(
        with theme: ParraTheme
    ) -> FeedbackFormWidgetStyle {
        let palette = theme.palette

        return FeedbackFormWidgetStyle(
            background: palette.primaryBackground,
            contentPadding: EdgeInsets(vertical: 12, horizontal: 20),
            cornerRadius: .zero,
            padding: EdgeInsets(top: 16, leading: 0, bottom: 0, trailing: 0)
        )
    }
}
