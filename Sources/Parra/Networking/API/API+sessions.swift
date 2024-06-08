//
//  API+sessions.swift
//  Parra
//
//  Created by Mick MacCallum on 5/1/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Foundation

extension API {
    func submitSession(
        _ sessionUpload: ParraSessionUpload
    ) async -> AuthenticatedRequestResult<ParraSessionsResponse> {
        return await apiResourceServer.hitApiEndpoint(
            endpoint: .postBulkSubmitSessions,
            config: .defaultWithRetries,
            body: sessionUpload
        )
    }
}
