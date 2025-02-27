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

extension ParraViewDataLoader {
    static func feedLoader(
        config: ParraFeedConfiguration
    )
        -> ParraViewDataLoader<
            FeedTransformParams,
            FeedParams,
            FeedWidget
        >
    {
        return ParraViewDataLoader<
            FeedTransformParams,
            FeedParams,
            FeedWidget
        >(
            renderer: { parra, params, navigationPath, _ in
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
                        contentTransformer: nil,
                        navigationPath: navigationPath
                    )

                return container
            }
        )
    }
}
