//
//  ParraAuthenticationProviderType+mockPublicKey.swift
//  Tests
//
//  Created by Mick MacCallum on 7/3/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation
@testable import Parra

extension ParraAuthenticationConfiguration {
    static func mockPublicKey(_ mockParra: MockParra)
        -> ParraAuthenticationConfiguration
    {
        return ParraAuthenticationConfiguration(
            workspaceId: mockParra.appState.tenantId,
            applicationId: mockParra.appState.applicationId,
            authenticationMethod: .publicKey(
                apiKeyId: UUID().uuidString,
                userIdProvider: {
                    return UUID().uuidString
                }
            )
        )
    }
}
