//
//  ProfileWidgetStyle.swift
//  Parra
//
//  Created by Mick MacCallum on 5/1/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

public struct ProfileWidgetStyle: WidgetStyle {
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
    ) -> ProfileWidgetStyle {
        let palette = theme.palette

        return ProfileWidgetStyle(
            background: palette.primaryBackground,
            contentPadding: EdgeInsets(vertical: 12, horizontal: 20),
            cornerRadius: .zero,
            padding: EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
        )
    }
}
