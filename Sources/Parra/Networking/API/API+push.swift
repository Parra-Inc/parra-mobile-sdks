//
//  API+push.swift
//  Parra
//
//  Created by Mick MacCallum on 5/1/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Foundation

extension API {
    func uploadPushToken(token: String) async throws {
        let body: [String: String] = [
            "token": token,
            "type": "apns"
        ]

        let _: EmptyResponseObject = try await hitEndpoint(
            .postPushTokens(tenantId: appState.tenantId),
            body: body
        )
    }
}
