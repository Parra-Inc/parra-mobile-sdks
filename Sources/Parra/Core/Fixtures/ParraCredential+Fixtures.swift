//
//  ParraCredential+Fixtures.swift
//  Parra
//
//  Created by Mick MacCallum on 4/5/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Foundation

extension ParraUser.Credential: ParraFixture {
    static func validStates() -> [ParraUser.Credential] {
        return [
            successResponse
        ]
    }

    static func invalidStates() -> [ParraUser.Credential] {
        return []
    }

    static let successResponse = ParraUser.Credential(
        token: UUID().uuidString
    )
}
