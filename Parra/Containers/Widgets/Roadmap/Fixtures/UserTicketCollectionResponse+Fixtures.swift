//
//  UserTicketCollectionResponse+Fixtures.swift
//  Parra
//
//  Created by Mick MacCallum on 3/5/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Foundation

extension UserTicketCollectionResponse: ParraFixture {
    static func validStates() -> [UserTicketCollectionResponse] {
        return [
            UserTicketCollectionResponse(
                page: 1,
                pageCount: 3,
                pageSize: 4,
                totalCount: 10,
                data: UserTicket.validStates()
            )
        ]
    }

    static func invalidStates() -> [UserTicketCollectionResponse] {
        return []
    }
}
