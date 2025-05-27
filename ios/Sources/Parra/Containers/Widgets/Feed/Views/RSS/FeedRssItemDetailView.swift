//
//  FeedRssItemDetailView.swift
//  Parra
//
//  Created by Mick MacCallum on 5/15/25.
//

import SwiftUI

struct FeedRssItemDetailView: View {
    // MARK: - Lifecycle

    init(
        rssItem: ParraAppRssItemData,
        feedItem: ParraFeedItem,
        reactor: StateObject<Reactor>,
        navigationPath: Binding<NavigationPath>,
        refreshOnAppear: Bool
    ) {
        self.rssItem = rssItem
        self.feedItem = feedItem
        self._reactor = reactor
        self._navigationPath = navigationPath
        self.refreshOnAppear = refreshOnAppear
    }

    // MARK: - Internal

    let rssItem: ParraAppRssItemData
    let feedItem: ParraFeedItem
    @StateObject var reactor: Reactor
    @Binding var navigationPath: NavigationPath
    let refreshOnAppear: Bool

    var body: some View {
        GeometryReader { geometry in
            let container: FeedCommentWidget = parra.parraInternal
                .containerRenderer.renderContainer(
                    params: FeedCommentWidget.ContentObserver.InitialParams(
                        feedItem: feedItem,
                        config: .default,
                        commentsResponse: nil,
                        attachmentPaywall: nil,
                        api: parra.parraInternal.api,
                        refreshOnAppear: refreshOnAppear
                    ),
                    config: ParraFeedCommentWidgetConfig(
                        headerViewBuilder: {
                            let cornerRadius = theme.cornerRadius.value(
                                for: .xl
                            )

                            FeedRssItemDetailHeaderView(
                                rssItem: rssItem,
                                feedItem: feedItem,
                                containerGeometry: geometry,
                                reactor: _reactor
                            )
                            .clipShape(
                                .rect(
                                    topLeadingRadius: 0,
                                    bottomLeadingRadius: cornerRadius.bottomLeading,
                                    bottomTrailingRadius: cornerRadius.bottomTrailing,
                                    topTrailingRadius: 0
                                )
                            )
                        }
                    ),
                    contentTransformer: nil,
                    navigationPath: $navigationPath
                )

            container
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        withContent(content: rssItem.link) { link in
                            Menu("Menu", systemImage: "ellipsis.circle") {
                                ShareLink(
                                    item: link,
                                    subject: nil,
                                    message: nil
                                ) {
                                    Label("Share", systemImage: "square.and.arrow.up")
                                }

                                Divider()

                                Link(destination: link) {
                                    Label(
                                        "Open in browser",
                                        systemImage: "rectangle.portrait.and.arrow.right"
                                    )
                                }
                            }
                        }
                    }
                }
                .toolbarBackground(
                    theme.palette.primaryBackground,
                    for: .navigationBar
                )
        }
    }

    // MARK: - Private

    @Environment(\.parraComponentFactory) private var componentFactory
    @Environment(\.parraTheme) private var theme
    @Environment(\.parra) private var parra
}
