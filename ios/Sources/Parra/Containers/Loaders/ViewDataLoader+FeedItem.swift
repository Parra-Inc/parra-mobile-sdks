//
//  ViewDataLoader+FeedItem.swift
//  Parra
//
//  Created by Mick MacCallum on 2/27/25.
//

import SwiftUI

struct FeedItemParams: Equatable {
    let feedItem: ParraFeedItem
}

struct FeedItemTransformParams: Equatable {
    let feedItemId: String
}

extension ParraViewDataLoader {
    static func feedItemLoader(
        config: ParraFeedConfiguration
    )
        -> ParraViewDataLoader<
            FeedItemTransformParams,
            FeedItemParams,
            ParraFeedItemView
        >
    {
        return ParraViewDataLoader<
            FeedItemTransformParams,
            FeedItemParams,
            ParraFeedItemView
        >(
            renderer: { parra, params, navigationPath, _ in
                let feedItem = params.feedItem

                let reactor = Reactor(
                    feedItemId: feedItem.id,
                    reactionOptionGroups: feedItem.reactionOptions?.elements ?? [],
                    reactions: feedItem.reactions?.elements ?? [],
                    api: parra.parraInternal.api,
                    submitReaction: { api, itemId, reactionOptionId in
                        return try await api.addFeedReaction(
                            feedItemId: itemId,
                            reactionOptionId: reactionOptionId
                        )
                    },
                    removeReaction: { api, itemId, reactionId in
                        try await api.removeFeedReaction(
                            feedItemId: itemId,
                            reactionId: reactionId
                        )
                    }
                )

                let contentObserver = FeedWidget.ContentObserver(
                    initialParams: FeedWidget.ContentObserver.InitialParams(
                        feedId: "",
                        config: config,
                        feedCollectionResponse: nil,
                        api: parra.parraInternal.api
                    )
                )

                return ParraFeedItemView(
                    feedItem: params.feedItem,
                    contentObserver: contentObserver,
                    reactor: StateObject(
                        wrappedValue: reactor
                    ),
                    navigationPath: navigationPath
                )
            }
        )
    }
}
