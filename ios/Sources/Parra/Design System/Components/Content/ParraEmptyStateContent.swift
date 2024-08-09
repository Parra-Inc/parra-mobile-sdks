//
//  ParraEmptyStateContent.swift
//  Parra
//
//  Created by Mick MacCallum on 3/13/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

public struct ParraEmptyStateContent: Hashable, Equatable {
    // MARK: - Lifecycle

    public init(
        title: ParraLabelContent,
        subtitle: ParraLabelContent? = nil,
        icon: ParraImageContent? = .symbol("tray"),
        primaryAction: ParraTextButtonContent? = nil,
        secondaryAction: ParraTextButtonContent? = nil
    ) {
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
        self.primaryAction = primaryAction
        self.secondaryAction = secondaryAction
    }

    // MARK: - Public

    public let title: ParraLabelContent
    public let subtitle: ParraLabelContent?
    public let icon: ParraImageContent?
    public private(set) var primaryAction: ParraTextButtonContent?
    public private(set) var secondaryAction: ParraTextButtonContent?

    // MARK: - Internal

    static let preview = ParraEmptyStateContent(
        title: ParraLabelContent(text: "No tickets yet"),
        subtitle: ParraLabelContent(
            text: "Iron rusts from disuse; water loses its purity from stagnation… even so does inaction sap the vigor of the mind.\t– Leonardo da Vinci"
        ),
        icon: .symbol("tray"),
        primaryAction: ParraTextButtonContent(
            text: ParraLabelContent(text: "Create a ticket"),
            isDisabled: false
        ),
        secondaryAction: ParraTextButtonContent(
            text: ParraLabelContent(text: "remind me later"),
            isDisabled: false
        )
    )

    static let errorGeneric = ParraEmptyStateContent(
        title: ParraLabelContent(text: "Something Went Wrong"),
        subtitle: ParraLabelContent(
            text: "An unexpected error occurred. Check your connection and try again later."
        ),
        icon: .symbol("exclamationmark.triangle")
    )
}
