//
//  AlertContent.swift
//  Parra
//
//  Created by Mick MacCallum on 3/7/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

public struct AlertContent: Hashable, Equatable {
    // MARK: - Lifecycle

    public init(
        title: LabelContent,
        subtitle: LabelContent?,
        icon: ParraImageContent?,
        dismiss: ImageButtonContent?
    ) {
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
        self.dismiss = dismiss
    }

    // MARK: - Public

    public let title: LabelContent
    public let subtitle: LabelContent?
    public let icon: ParraImageContent?
    public private(set) var dismiss: ImageButtonContent?

    public static func defaultIcon(
        for style: AlertLevel
    ) -> ParraImageContent {
        let symbolName = switch style {
        case .success:
            "checkmark.circle"
        case .info:
            "info.circle"
        case .warn:
            "exclamationmark.triangle"
        case .error:
            "xmark.circle"
        }

        return ParraImageContent.symbol(symbolName, .monochrome)
    }

    public static func defaultDismiss(
        for style: AlertLevel,
        onPress: (() -> Void)? = nil
    ) -> ImageButtonContent {
        return ImageButtonContent(
            image: ParraImageContent.symbol("xmark", .monochrome),
            isDisabled: false
        )
    }
}
