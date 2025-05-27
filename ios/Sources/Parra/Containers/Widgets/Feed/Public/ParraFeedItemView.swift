//
//  ParraFeedItemView.swift
//  Parra
//
//  Created by Mick MacCallum on 3/6/25.
//

import SwiftUI

struct ParraFeedItemView: View {
    // MARK: - Lifecycle

    init(
        feedItem: ParraFeedItem,
        contentObserver: FeedWidget.ContentObserver,
        reactor: StateObject<Reactor>,
        navigationPath: Binding<NavigationPath>
    ) {
        self.feedItem = feedItem
        self.contentObserver = contentObserver
        self._reactor = reactor
        self._navigationPath = navigationPath
    }

    // MARK: - Internal

    var feedItem: ParraFeedItem
    var contentObserver: FeedWidget.ContentObserver
    @StateObject var reactor: Reactor
    @Binding var navigationPath: NavigationPath

    var body: some View {
        content.environmentObject(contentObserver)
    }

    // MARK: - Private

    @ViewBuilder private var content: some View {
        switch feedItem.data {
        case .contentCard:
            // TODO: Also need a content card detail view to present here.
            EmptyView()
        case .creatorUpdate(let creatorUpdate):
            FeedCreatorUpdateDetailView(
                creatorUpdate: creatorUpdate,
                feedItem: feedItem,
                reactor: _reactor,
                navigationPath: $navigationPath
            )
        case .feedItemYoutubeVideo(let youtubeVideo):
            FeedYouTubeVideoDetailView(
                youtubeVideo: youtubeVideo,
                feedItem: feedItem,
                reactor: _reactor,
                navigationPath: $navigationPath
            )
        case .appRssItem(let rssItem):
            FeedRssItemDetailView(
                rssItem: rssItem,
                feedItem: feedItem,
                reactor: _reactor,
                navigationPath: $navigationPath,
                refreshOnAppear: false
            )
        }
    }
}
