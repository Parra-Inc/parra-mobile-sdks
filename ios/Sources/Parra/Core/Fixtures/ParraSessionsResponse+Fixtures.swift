//
//  ParraSessionsResponse+Fixtures.swift
//  Parra
//
//  Created by Mick MacCallum on 4/5/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Foundation

extension ParraSessionsResponse: ParraFixture {
    public static func validStates() -> [ParraSessionsResponse] {
        return [
            successResponse,
            pollResponse
        ]
    }

    public static func invalidStates() -> [ParraSessionsResponse] {
        return []
    }

    static let successResponse = ParraSessionsResponse(
        shouldPoll: false,
        retryDelay: 0,
        retryTimes: 0
    )

    static let pollResponse = ParraSessionsResponse(
        shouldPoll: true,
        retryDelay: 15,
        retryTimes: 5
    )
}
