//
//  FeedWidget.swift
//  Parra
//
//  Created by Mick MacCallum on 9/25/24.
//

import SwiftUI

// TODO:
// 1. Ability to present in sheet

struct FeedWidget: Container {
    // MARK: - Lifecycle

    init(
        config: ParraFeedConfiguration,
        contentObserver: ContentObserver
    ) {
        self.config = config
        self._contentObserver = StateObject(wrappedValue: contentObserver)
    }

    // MARK: - Internal

    @StateObject var contentObserver: ContentObserver
    let config: ParraFeedConfiguration

    var items: Binding<[FeedItem]> {
        return $contentObserver.feedPaginator.items
    }

    var body: some View {
        let defaultWidgetAttributes = ParraAttributes.Widget.default(
            with: parraTheme
        )

        let contentPadding = parraTheme.padding.value(
            for: defaultWidgetAttributes.contentPadding
        )

        scrollView(with: contentPadding)
            .applyWidgetAttributes(
                attributes: defaultWidgetAttributes.withoutContentPadding(),
                using: parraTheme
            )
            .environment(config)
            .environment(componentFactory)
            .environmentObject(contentObserver)
            .onAppear {
                contentObserver.loadInitialFeedItems()
            }
    }

    func scrollView(
        with contentPadding: EdgeInsets
    ) -> some View {
        GeometryReader { geometry in
            ScrollView {
                LazyVStack(alignment: .center, spacing: 0) {
                    createCells(with: geometry)

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
                .vertical,
                headerSpace(from: contentPadding) / 2,
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
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass

    @ViewBuilder
    private func createCells(
        with containerGeometry: GeometryProxy
    ) -> some View {
        ForEach(items.wrappedValue) { item in
            switch item.data {
            case .feedItemYoutubeVideoData(let data):
                FeedYouTubeVideoView(youtubeVideo: data)
            case .contentCard(let data):
                FeedContentCardView(
                    contentCard: data,
                    containerGeometry: containerGeometry
                )
            default:
                EmptyView()
            }
        }
    }
}

#Preview {
    ParraContainerPreview<FeedWidget> { parra, _, config in
        FeedWidget(
            config: .default,
            contentObserver: .init(
                initialParams: FeedWidget.ContentObserver
                    .InitialParams(
                        feedId: "test-feed-id",
                        config: .default,
                        feedCollectionResponse: .validStates()[0],
                        api: parra.parraInternal.api
                    )
            )
        )
    }
}
