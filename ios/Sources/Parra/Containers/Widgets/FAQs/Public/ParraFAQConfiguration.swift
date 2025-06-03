//
//  ParraFAQConfiguration.swift
//  Parra
//
//  Created by Mick MacCallum on 12/3/24.
//

import Foundation

public final class ParraFAQConfiguration: ParraContainerConfig {
    // MARK: - Lifecycle

    public init() {
        self.emptyStateContent = ParraFAQConfiguration.defaultEmptyStateContent
        self.errorStateContent = ParraFAQConfiguration.defaultErrorStateContent
    }

    public init(
        emptyStateContent: ParraEmptyStateContent,
        errorStateContent: ParraEmptyStateContent
    ) {
        self.emptyStateContent = emptyStateContent
        self.errorStateContent = errorStateContent
    }

    // MARK: - Public

    public static let `default` = ParraFAQConfiguration()

    public static let defaultEmptyStateContent = ParraEmptyStateContent(
        title: ParraLabelContent(
            text: "No FAQs Yet"
        ),
        subtitle: ParraLabelContent(
            text: "Check back later"
        )
    )

    public static let defaultErrorStateContent = ParraEmptyStateContent(
        title: ParraEmptyStateContent.errorGeneric.title,
        subtitle: ParraLabelContent(
            text: "Failed to load FAQs. Please try again later."
        ),
        icon: .symbol("network.slash", .monochrome)
    )

    public let emptyStateContent: ParraEmptyStateContent
    public let errorStateContent: ParraEmptyStateContent
}
