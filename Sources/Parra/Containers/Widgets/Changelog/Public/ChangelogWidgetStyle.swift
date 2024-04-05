//
//  ChangelogWidgetStyle.swift
//  Parra
//
//  Created by Mick MacCallum on 3/15/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

public struct ChangelogWidgetStyle: WidgetStyle {
    // MARK: - Lifecycle

    public init(
        background: (any ShapeStyle)?,
        contentPadding: EdgeInsets,
        cornerRadius: ParraCornerRadiusSize,
        padding: EdgeInsets,
        releasePreviewNames: LabelAttributes = .init(),
        releasePreviewDescriptions: LabelAttributes = .init(),
        releaseDetailTitle: LabelAttributes = .init(),
        releaseDetailSubtitle: LabelAttributes = .init(),
        releaseDetailHeaderImage: ImageAttributes = .init(),
        releaseDetailDescription: LabelAttributes = .init(),
        emptyState: EmptyStateAttributes = .init(),
        errorState: EmptyStateAttributes = .init()
    ) {
        self.background = background
        self.contentPadding = contentPadding
        self.cornerRadius = cornerRadius
        self.padding = padding
        self.releasePreviewNames = releasePreviewNames
        self.releasePreviewDescriptions = releasePreviewDescriptions
        self.releaseDetailTitle = releaseDetailTitle
        self.releaseDetailSubtitle = releaseDetailSubtitle
        self.releaseDetailHeaderImage = releaseDetailHeaderImage
        self.releaseDetailDescription = releaseDetailDescription
        self.emptyState = emptyState
        self.errorState = errorState
    }

    // MARK: - Public

    public let background: (any ShapeStyle)?
    public let contentPadding: EdgeInsets
    public let cornerRadius: ParraCornerRadiusSize
    public let padding: EdgeInsets

    public let releasePreviewNames: LabelAttributes
    public let releasePreviewDescriptions: LabelAttributes

    public let releaseDetailTitle: LabelAttributes
    public let releaseDetailSubtitle: LabelAttributes
    public let releaseDetailHeaderImage: ImageAttributes
    public let releaseDetailDescription: LabelAttributes

    public let emptyState: EmptyStateAttributes
    public let errorState: EmptyStateAttributes

    public static func `default`(
        with theme: ParraTheme
    ) -> ChangelogWidgetStyle {
        let palette = theme.palette

        return ChangelogWidgetStyle(
            background: palette.primaryBackground,
            contentPadding: .padding(vertical: 12, horizontal: 20),
            cornerRadius: .zero,
            padding: .padding(top: 16),
            releaseDetailHeaderImage: ImageAttributes(
                cornerRadius: .sm
            )
        )
    }
}
