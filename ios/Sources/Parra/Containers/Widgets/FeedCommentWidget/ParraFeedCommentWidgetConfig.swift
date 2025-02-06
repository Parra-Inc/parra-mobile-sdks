//
//  ParraFeedCommentWidgetConfig.swift
//  Parra
//
//  Created by Mick MacCallum on 12/18/24.
//

import SwiftUI

public final class ParraFeedCommentWidgetConfig: ParraContainerConfig {
    // MARK: - Lifecycle

    public init() {
        self.headerViewBuilder = { EmptyView() }
        self.footerViewBuilder = { EmptyView() }
        self.emptyStateContent = ParraFeedCommentWidgetConfig.defaultEmptyStateContent
        self.errorStateContent = ParraFeedCommentWidgetConfig.defaultErrorStateContent
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
        emptyStateContent: ParraEmptyStateContent = ParraFeedCommentWidgetConfig
            .defaultEmptyStateContent,
        errorStateContent: ParraEmptyStateContent = ParraFeedCommentWidgetConfig
            .defaultErrorStateContent
    ) {
        self.headerViewBuilder = headerViewBuilder
        self.footerViewBuilder = footerViewBuilder
        self.emptyStateContent = emptyStateContent
        self.errorStateContent = errorStateContent
    }

    // MARK: - Public

    public static let `default` = ParraFeedCommentWidgetConfig()

    public static let defaultEmptyStateContent = ParraEmptyStateContent(
        title: ParraLabelContent(
            text: "Nothing here yet"
        ),
        subtitle: ParraLabelContent(
            text: "This is the beginning of the chat. Add your first comment!"
        ),
        icon: nil
    )

    public static let defaultErrorStateContent = ParraEmptyStateContent(
        title: ParraEmptyStateContent.errorGeneric.title,
        subtitle: ParraLabelContent(
            text: "Failed to load comments. Please try again later."
        ),
        icon: nil
    )

    public let headerViewBuilder: @MainActor () -> any View
    public let footerViewBuilder: @MainActor () -> any View

    public let emptyStateContent: ParraEmptyStateContent
    public let errorStateContent: ParraEmptyStateContent
}
