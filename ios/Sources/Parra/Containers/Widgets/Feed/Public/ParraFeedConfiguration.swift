//
//  ParraFeedConfiguration.swift
//  Parra
//
//  Created by Mick MacCallum on 9/25/24.
//

import SwiftUI

public final class ParraFeedConfiguration: ParraContainerConfig {
    // MARK: - Lifecycle

    public init() {
        self.headerViewBuilder = { EmptyView() }
        self.footerViewBuilder = { EmptyView() }
        self.shouldPerformDefaultActionForItem = { _ in true }
        self.feedDidRefresh = {}
        self.navigationTitle = "Feed"
        self.itemSpacing = 16
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
        @ViewBuilder feedListBuilder: @escaping @MainActor (
            _ items: [ParraFeedItem],
            _ itemSpacing: CGFloat,
            _ containerGeometry: GeometryProxy,
            _ navigationPath: Binding<NavigationPath>,
            _ itemAtIndexDidAppear: @escaping (_: Int) -> Void,
            _ performActionForFeedItemData: @escaping (_: ParraFeedItemData) -> Void
        )
            -> some View =
            { items, itemSpacing, containerGeometry, navigationPath, itemAtIndexDidAppear, performActionForFeedItemData in
                return ParraFeedListView(
                    items: items,
                    itemSpacing: itemSpacing,
                    containerGeometry: containerGeometry,
                    navigationPath: navigationPath,
                    itemAtIndexDidAppear: itemAtIndexDidAppear,
                    performActionForFeedItemData: performActionForFeedItemData
                )
            },
        shouldPerformDefaultActionForItem: @escaping (ParraFeedItemData) -> Bool = { _ in
            true
        },
        feedDidRefresh: @escaping () -> Void = {},
        navigationTitle: String = "Feed",
        itemSpacing: CGFloat = 16,
        emptyStateContent: ParraEmptyStateContent = ParraFeedConfiguration
            .defaultEmptyStateContent,
        errorStateContent: ParraEmptyStateContent = ParraFeedConfiguration
            .defaultErrorStateContent
    ) {
        self.headerViewBuilder = headerViewBuilder
        self.footerViewBuilder = footerViewBuilder
        self.shouldPerformDefaultActionForItem = shouldPerformDefaultActionForItem
        self.feedDidRefresh = feedDidRefresh
        self.navigationTitle = navigationTitle
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

    public let shouldPerformDefaultActionForItem: (ParraFeedItemData) -> Bool
    public let feedDidRefresh: () -> Void

    public let navigationTitle: String
    public let itemSpacing: CGFloat

    public let emptyStateContent: ParraEmptyStateContent
    public let errorStateContent: ParraEmptyStateContent
}
