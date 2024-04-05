//
//  EmptyStateContent.swift
//  Parra
//
//  Created by Mick MacCallum on 3/13/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

public struct EmptyStateContent: Hashable, Equatable {
    // MARK: - Lifecycle

    public init(
        title: LabelContent,
        subtitle: LabelContent? = nil,
        icon: ImageContent? = .symbol("tray"),
        primaryAction: TextButtonContent? = nil,
        secondaryAction: TextButtonContent? = nil
    ) {
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
        self.primaryAction = primaryAction
        self.secondaryAction = secondaryAction
    }

    // MARK: - Public

    public let title: LabelContent
    public let subtitle: LabelContent?
    public let icon: ImageContent?
    public private(set) var primaryAction: TextButtonContent?
    public private(set) var secondaryAction: TextButtonContent?

    // MARK: - Internal

    static let preview = EmptyStateContent(
        title: LabelContent(text: "No tickets yet"),
        subtitle: LabelContent(
            text: "Iron rusts from disuse; water loses its purity from stagnation… even so does inaction sap the vigor of the mind.\t– Leonardo da Vinci"
        ),
        icon: .symbol("tray"),
        primaryAction: TextButtonContent(
            text: LabelContent(text: "Create a ticket"),
            isDisabled: false
        ),
        secondaryAction: TextButtonContent(
            text: LabelContent(text: "remind me later"),
            isDisabled: false
        )
    )

    static let errorGeneric = EmptyStateContent(
        title: LabelContent(text: "Something Went Wrong"),
        subtitle: LabelContent(
            text: "An unexpected error occurred. Check your connection and try again later."
        ),
        icon: .symbol("exclamationmark.triangle")
    )
}
