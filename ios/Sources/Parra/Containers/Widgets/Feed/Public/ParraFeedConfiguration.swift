//
//  ParraFeedConfiguration.swift
//  Parra
//
//  Created by Mick MacCallum on 9/25/24.
//

import SwiftUI

public final class ParraFeedConfiguration: ContainerConfig {
    // MARK: - Lifecycle

    public init() {
        self.headerViewBuilder = { EmptyView() }
        self.footerViewBuilder = { EmptyView() }
        self.itemSpacing = 12
        self.emptyStateContent = ParraFeedConfiguration.defaultEmptyStateContent
        self.errorStateContent = ParraFeedConfiguration.defaultErrorStateContent
    }

    public init(
        @ViewBuilder headerViewBuilder: @escaping @MainActor () -> some View = {
            EmptyView()
        },
        @ViewBuilder footerViewBuilder: @escaping @MainActor () -> some View = {
            EmptyView()
        },
        itemSpacing: CGFloat = 12,
        emptyStateContent: ParraEmptyStateContent = ParraFeedConfiguration
            .defaultEmptyStateContent,
        errorStateContent: ParraEmptyStateContent = ParraFeedConfiguration
            .defaultErrorStateContent
    ) {
        self.headerViewBuilder = headerViewBuilder
        self.footerViewBuilder = footerViewBuilder
        self.itemSpacing = itemSpacing
        self.emptyStateContent = emptyStateContent
        self.errorStateContent = errorStateContent
    }

    // MARK: - Public

    public static let `default` = ParraFeedConfiguration()

    public static let defaultEmptyStateContent = ParraEmptyStateContent(
        title: ParraLabelContent(
            text: "Nothing here yet"
        ),
        subtitle: ParraLabelContent(
            text: "Check back later for new content!"
        )
    )

    public static let defaultErrorStateContent = ParraEmptyStateContent(
        title: ParraEmptyStateContent.errorGeneric.title,
        subtitle: ParraLabelContent(
            text: "Failed to load content feed. Please try again later."
        ),
        icon: .symbol("network.slash", .monochrome)
    )

    public let headerViewBuilder: @MainActor () -> any View
    public let footerViewBuilder: @MainActor () -> any View

    public let itemSpacing: CGFloat

    public let emptyStateContent: ParraEmptyStateContent
    public let errorStateContent: ParraEmptyStateContent
}
