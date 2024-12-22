//
//  FeedCommentWidgetConfig.swift
//  Parra
//
//  Created by Mick MacCallum on 12/18/24.
//

import SwiftUI

public final class FeedCommentWidgetConfig: ParraContainerConfig {
    // MARK: - Lifecycle

    public init() {
        self.headerViewBuilder = { EmptyView() }
        self.footerViewBuilder = { EmptyView() }
        self.emptyStateContent = FeedCommentWidgetConfig.defaultEmptyStateContent
        self.errorStateContent = FeedCommentWidgetConfig.defaultErrorStateContent
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
            _ itemAtIndexDidAppear: @escaping (_: Int) -> Void,
            _ performActionForFeedItemData: @escaping (_: ParraFeedItemData) -> Void
        )
            -> some View =
            { items, itemSpacing, containerGeometry, itemAtIndexDidAppear, performActionForFeedItemData in
                return ParraFeedListView(
                    items: items,
                    itemSpacing: itemSpacing,
                    containerGeometry: containerGeometry,
                    itemAtIndexDidAppear: itemAtIndexDidAppear,
                    performActionForFeedItemData: performActionForFeedItemData
                )
            },
        emptyStateContent: ParraEmptyStateContent = FeedCommentWidgetConfig
            .defaultEmptyStateContent,
        errorStateContent: ParraEmptyStateContent = FeedCommentWidgetConfig
            .defaultErrorStateContent
    ) {
        self.headerViewBuilder = headerViewBuilder
        self.footerViewBuilder = footerViewBuilder
        self.emptyStateContent = emptyStateContent
        self.errorStateContent = errorStateContent
    }

    // MARK: - Public

    public static let `default` = FeedCommentWidgetConfig()

    public static let defaultEmptyStateContent = ParraEmptyStateContent(
        title: ParraLabelContent(
            text: "No comments"
        ),
        subtitle: ParraLabelContent(
            text: "Check back later!"
        )
    )

    public static let defaultErrorStateContent = ParraEmptyStateContent(
        title: ParraEmptyStateContent.errorGeneric.title,
        subtitle: ParraLabelContent(
            text: "Failed to load comments. Please try again later."
        ),
        icon: .symbol("network.slash", .monochrome)
    )

    public let headerViewBuilder: @MainActor () -> any View
    public let footerViewBuilder: @MainActor () -> any View

    public let emptyStateContent: ParraEmptyStateContent
    public let errorStateContent: ParraEmptyStateContent
}
