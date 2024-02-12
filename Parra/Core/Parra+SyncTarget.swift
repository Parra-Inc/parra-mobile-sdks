//
//  Parra+SyncTarget.swift
//  Parra
//
//  Created by Mick MacCallum on 2/10/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Foundation

// Parra is itself a sync target. The top level manager will facilitate syncs
// that transfer state between its children.
extension Parra: SyncTarget {
    func hasDataToSync(since date: Date?) async -> Bool {
        await sessionManager.hasDataToSync(since: date)
    }

    func synchronizeData() async throws {
        guard let response = try await sessionManager.synchronizeData() else {
            return
        }

        feedback.didReceiveSessionResponse(sessionResponse: response)
    }
}
