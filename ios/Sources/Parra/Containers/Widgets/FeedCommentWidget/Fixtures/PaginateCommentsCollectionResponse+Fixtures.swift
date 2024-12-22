//
//  PaginateCommentsCollectionResponse+Fixtures.swift
//  Parra
//
//  Created by Mick MacCallum on 12/17/24.
//

import Foundation

extension PaginateCommentsCollectionResponse: ParraFixture {
    static func validStates() -> [PaginateCommentsCollectionResponse] {
        return [
            PaginateCommentsCollectionResponse(
                page: 1,
                pageCount: 3,
                pageSize: 15,
                totalCount: 45,
                data: ParraComment.validStates()
            )
        ]
    }
}
