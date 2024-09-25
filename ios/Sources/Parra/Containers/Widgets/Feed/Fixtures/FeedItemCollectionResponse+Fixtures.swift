//
//  FeedItemCollectionResponse+Fixtures.swift
//  Parra
//
//  Created by Mick MacCallum on 9/25/24.
//

import SwiftUI

extension FeedItemCollectionResponse: ParraFixture {
    static func validStates() -> [FeedItemCollectionResponse] {
        return [
            FeedItemCollectionResponse(
                page: 1,
                pageCount: 1,
                pageSize: 25,
                totalCount: 2,
                data: FeedItem.validStates()
            )
        ]
    }

    static func invalidStates() -> [FeedItemCollectionResponse] {
        return [
            FeedItemCollectionResponse(
                page: 1,
                pageCount: 3,
                pageSize: 4,
                totalCount: 10,
                data: FeedItem.invalidStates()
            )
        ]
    }
}
