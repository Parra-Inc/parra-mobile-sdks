//
//  ParraAlertContent.swift
//  Parra
//
//  Created by Mick MacCallum on 3/7/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

public struct ParraAlertContent: Hashable, Equatable {
    // MARK: - Lifecycle

    public init(
        title: ParraLabelContent,
        subtitle: ParraLabelContent?,
        icon: ParraImageContent?,
        dismiss: ParraImageButtonContent?
    ) {
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
        self.dismiss = dismiss
    }

    // MARK: - Public

    public let title: ParraLabelContent
    public let subtitle: ParraLabelContent?
    public let icon: ParraImageContent?
    public private(set) var dismiss: ParraImageButtonContent?

    public static func defaultIcon(
        for style: ParraAlertLevel
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
        for style: ParraAlertLevel,
        onPress: (() -> Void)? = nil
    ) -> ParraImageButtonContent {
        return ParraImageButtonContent(
            image: ParraImageContent.symbol("xmark", .monochrome),
            isDisabled: false
        )
    }
}
