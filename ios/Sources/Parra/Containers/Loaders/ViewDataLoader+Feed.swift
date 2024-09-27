//
//  ViewDataLoader+Feed.swift
//  Parra
//
//  Created by Mick MacCallum on 9/26/24.
//

import SwiftUI

private let logger = Logger()

struct FeedParams: Equatable {
    let feedId: String
    let feedCollectionResponse: FeedItemCollectionResponse
}

struct FeedTransformParams: Equatable {
    let feedId: String
}

extension ViewDataLoader {
    static func feedLoader(
        feedId: String,
        config: ParraFeedConfiguration
    )
        -> ViewDataLoader<
            FeedTransformParams,
            FeedParams,
            FeedWidget
        >
    {
        return ViewDataLoader<
            FeedTransformParams,
            FeedParams,
            FeedWidget
        >(
            renderer: { parra, params, _ in
                let container: FeedWidget = parra.parraInternal
                    .containerRenderer
                    .renderContainer(
                        params: FeedWidget.ContentObserver.InitialParams(
                            feedId: params.feedId,
                            config: config,
                            feedCollectionResponse: params.feedCollectionResponse,
                            api: parra.parraInternal.api
                        ),
                        config: config,
                        contentTransformer: nil
                    )

                return container
            }
        )
    }
}
