//
//  AlertConfig.swift
//  Parra
//
//  Created by Mick MacCallum on 3/7/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

public struct AlertConfig: Equatable {
    // MARK: - Lifecycle

    public init(
        style: Style = AlertConfig.default.style,
        title: LabelConfig = AlertConfig.default.title,
        subtitle: LabelConfig = AlertConfig.default.subtitle,
        dismiss: ImageButtonConfig = AlertConfig.default.dismiss
    ) {
        self.style = style
        self.title = title
        self.subtitle = subtitle
        self.dismiss = dismiss
    }

    // MARK: - Public

    public enum Style: CaseIterable {
        case success
        case info
        case warn
        case error
    }

    public static let `default` = AlertConfig(
        style: .info,
        title: LabelConfig(fontStyle: .headline),
        subtitle: LabelConfig(fontStyle: .subheadline),
        dismiss: ImageButtonConfig(
            style: .secondary,
            size: .custom(defaultDismissButtonSize),
            variant: .plain
        )
    )

    public static let defaultWhatsNew = AlertConfig(
        style: .info,
        title: LabelConfig(fontStyle: .headline),
        subtitle: LabelConfig(fontStyle: .subheadline),
        dismiss: ImageButtonConfig(
            style: .secondary,
            size: .custom(defaultDismissButtonSize),
            variant: .plain
        )
    )

    public let style: Style
    public let title: LabelConfig
    public let subtitle: LabelConfig
    public let dismiss: ImageButtonConfig

    // MARK: - Internal

    static let defaultDismissButtonSize = CGSize(width: 12, height: 12)
}
