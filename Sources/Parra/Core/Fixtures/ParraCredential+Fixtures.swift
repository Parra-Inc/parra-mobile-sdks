//
//  ParraCredential+Fixtures.swift
//  Parra
//
//  Created by Mick MacCallum on 4/5/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Foundation

extension ParraCredential: ParraFixture {
    static func validStates() -> [ParraCredential] {
        return [
            successResponse
        ]
    }

    static func invalidStates() -> [ParraCredential] {
        return []
    }

    static let successResponse = ParraCredential(
        token: UUID().uuidString
    )
}
