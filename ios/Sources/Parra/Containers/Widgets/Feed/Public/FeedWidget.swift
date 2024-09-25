//
//  FeedWidget.swift
//  Parra
//
//  Created by Mick MacCallum on 9/25/24.
//

import SwiftUI

struct FeedWidget: Container {
    // MARK: - Lifecycle

    init(
        config: ParraRoadmapWidgetConfig,
        contentObserver: ContentObserver
    ) {
        self.config = config
        self._contentObserver = StateObject(wrappedValue: contentObserver)
    }

    // MARK: - Internal

    @StateObject var contentObserver: ContentObserver
    let config: ParraRoadmapWidgetConfig

    var items: Binding<[FeedItem]> {
        return $contentObserver.feedPaginator.items
    }

    @ViewBuilder var cells: some View {
        ForEach(items) { item in
            Text(item.id)
        }
    }

    var body: some View {
        let defaultWidgetAttributes = ParraAttributes.Widget.default(
            with: parraTheme
        )

        let contentPadding = parraTheme.padding.value(
            for: defaultWidgetAttributes.contentPadding
        )

        VStack(spacing: 0) {
            scrollView(with: contentPadding)
        }
        .applyWidgetAttributes(
            attributes: defaultWidgetAttributes.withoutContentPadding(),
            using: parraTheme
        )
        .environment(config)
        .environment(componentFactory)
        .environmentObject(contentObserver)
    }

    func scrollView(
        with contentPadding: EdgeInsets
    ) -> some View {
        ScrollViewReader { _ in
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 12) {
                    cells

                    if contentObserver.feedPaginator.isLoading {
                        VStack(alignment: .center) {
                            ProgressView()
                        }
                        .frame(maxWidth: .infinity)
                        .padding(contentPadding)
                    }
                }
                .redacted(
                    when: contentObserver.feedPaginator.isShowingPlaceholders
                )
            }
            // A limited number of placeholder cells will be generated.
            // Don't allow scrolling past them while loading.
            .scrollDisabled(
                contentObserver.feedPaginator.isShowingPlaceholders
            )
            .contentMargins(
                .top,
                headerSpace(from: contentPadding) / 2,
                for: .scrollContent
            )
            .contentMargins(
                [.leading, .trailing, .bottom],
                contentPadding,
                for: .scrollContent
            )
            .emptyPlaceholder(items) {
                componentFactory.buildEmptyState(
                    config: .default,
                    content: contentObserver.content.emptyStateView
                )
            }
            .errorPlaceholder(contentObserver.feedPaginator.error) {
                componentFactory.buildEmptyState(
                    config: .errorDefault,
                    content: contentObserver.content.errorStateView
                )
            }
            .refreshable {
                contentObserver.feedPaginator.refresh()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .coordinateSpace(name: "scroll")
        }
    }

    func headerSpace(
        from contentPadding: EdgeInsets
    ) -> CGFloat {
        return contentPadding.bottom
    }

    // MARK: - Private

    @Environment(\.parraComponentFactory) private var componentFactory
    @Environment(\.parraTheme) private var parraTheme
}

#Preview {
    ParraContainerPreview<FeedWidget> {
        parra,
            _,
            config in
        FeedWidget(
            config: .default,
            contentObserver: .init(
                initialParams: FeedWidget.ContentObserver
                    .InitialParams(
                        feedConfig: ParraFeedConfiguration(),
                        feedCollectionResponse: .validStates()[0],
                        api: parra.parraInternal.api
                    )
            )
        )
    }
}
