//
//  FeedbackCardWidgetStyle.swift
//  Parra
//
//  Created by Mick MacCallum on 2/24/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

public struct FeedbackCardWidgetStyle: WidgetStyle {
    public let background: (any ShapeStyle)?
    public let contentPadding: EdgeInsets
    public let cornerRadius: ParraCornerRadiusSize
    public let padding: EdgeInsets

    public static func `default`(
        with theme: ParraTheme
    ) -> FeedbackCardWidgetStyle {
        let palette = theme.palette

        return FeedbackCardWidgetStyle(
            background: palette.primaryBackground,
            contentPadding: EdgeInsets(
                top: 12,
                leading: 16,
                bottom: 8,
                trailing: 16
            ),
            cornerRadius: ParraCornerRadiusSize.large,
            padding: .zero
        )
    }
}
