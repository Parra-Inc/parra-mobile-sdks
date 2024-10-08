//
//  UserTicketCollectionResponse+Fixtures.swift
//  Parra
//
//  Created by Mick MacCallum on 3/5/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Foundation

extension ParraUserTicketCollectionResponse: ParraFixture {
    public static func validStates() -> [ParraUserTicketCollectionResponse] {
        return [
            ParraUserTicketCollectionResponse(
                page: 1,
                pageCount: 3,
                pageSize: 4,
                totalCount: 10,
                data: ParraUserTicket.validStates()
            )
        ]
    }

    public static func invalidStates() -> [ParraUserTicketCollectionResponse] {
        return []
    }
}
