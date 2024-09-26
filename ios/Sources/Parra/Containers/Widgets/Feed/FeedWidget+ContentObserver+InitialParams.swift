//
//  FeedWidget+ContentObserver+InitialParams.swift
//  Parra
//
//  Created by Mick MacCallum on 9/25/24.
//

import SwiftUI

extension FeedWidget.ContentObserver {
    struct InitialParams {
        let feedId: String
        let config: ParraFeedConfiguration
        let feedCollectionResponse: FeedItemCollectionResponse?
        let api: API
    }
}
