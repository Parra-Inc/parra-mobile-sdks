//
//  ParraAuthenticationProviderType+mockPublicKey.swift
//  Tests
//
//  Created by Mick MacCallum on 7/3/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation
@testable import Parra

extension ParraAuthenticationMethod {
    static func mockPublicKey(_ mockParra: MockParra)
        -> ParraAuthenticationMethod
    {
        return .public(
            apiKeyId: UUID().uuidString,
            userIdProvider: {
                return UUID().uuidString
            }
        )
    }
}
