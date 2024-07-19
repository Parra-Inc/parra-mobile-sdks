//
//  UserInfoResponse+Fixtures.swift
//  Parra
//
//  Created by Mick MacCallum on 4/17/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Foundation

extension UserInfoResponse: ParraFixture {
    static let publicFacingPreview = UserInfoResponse(
        roles: ["user"],
        user: .publicFacingPreview
    )

    static func validStates() -> [UserInfoResponse] {
        return [
            publicFacingPreview
        ]
    }

    static func invalidStates() -> [UserInfoResponse] {
        return []
    }
}
