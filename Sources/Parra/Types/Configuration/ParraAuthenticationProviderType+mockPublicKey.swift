//
//  ParraAuthenticationProviderType+mockPublicKey.swift
//  ParraTests
//
//  Created by Mick MacCallum on 7/3/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation
@testable import Parra

extension ParraAuthenticationProviderType {
    static func mockPublicKey(_ mockParra: MockParra)
        -> ParraAuthenticationProviderType
    {
        return .publicKey(
            tenantId: mockParra.appState.tenantId,
            applicationId: mockParra.appState.applicationId,
            apiKeyId: UUID().uuidString,
            userIdProvider: {
                return UUID().uuidString
            }
        )
    }
}
