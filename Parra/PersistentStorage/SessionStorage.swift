//
//  SessionStorage.swift
//  Parra
//
//  Created by Mick MacCallum on 11/20/22.
//  Copyright © 2022 Parra, Inc. All rights reserved.
//

import Foundation

internal actor SessionStorage: ItemStorage {
    typealias DataType = ParraSession

    let storageModule: ParraStorageModule<ParraSession>

    init(storageModule: ParraStorageModule<ParraSession>) {
        self.storageModule = storageModule
    }

    func update(session: ParraSession) async {
        do {
            try await storageModule.write(
                name: session.sessionId,
                value: session
            )
        } catch let error {
            Logger.error("Error storing session", error, [
                "sessionId": session.sessionId
            ])
        }
    }

    func deleteSessions(with sessionIds: Set<String>) async {
        for sessionId in sessionIds {
            await storageModule.delete(name: sessionId)
        }
    }

    func allTrackedSessions() async -> [ParraSession] {
        let sessions = await storageModule.currentData()

        return sessions.sorted { (first, second) in
            let firstKey = Float(first.key) ?? 0
            let secondKey = Float(second.key) ?? 0

            return firstKey < secondKey
        }.map { (key: String, value: ParraSession) in
            return value
        }
    }

    func numberOfTrackedSessions() async -> Int {
        let sessions = await storageModule.currentData()

        return sessions.count
    }
}
