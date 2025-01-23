//
//  ParraAlertContent.swift
//  Parra
//
//  Created by Mick MacCallum on 3/7/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

public struct ParraAlertContent: Hashable, Equatable, Sendable {
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

    public static let defaultSessionExpired: ParraAlertContent = .init(
        title: ParraLabelContent(text: "Session expired"),
        subtitle: ParraLabelContent(
            text: "You have been automatically logged out"
        ),
        icon: .symbol("clock.badge.exclamationmark"),
        dismiss: nil
    )

    public let title: ParraLabelContent
    public let subtitle: ParraLabelContent?
    public let icon: ParraImageContent?
    public private(set) var dismiss: ParraImageButtonContent?

    public static func defaultIcon(
        for style: ParraAlertLevel
    ) -> ParraImageContent {
        let symbolName = switch style {
        case .success:
            "checkmark.circle.fill"
        case .info:
            "info.circle.fill"
        case .warn:
            "exclamationmark.triangle.fill"
        case .error:
            "xmark.circle.fill"
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
