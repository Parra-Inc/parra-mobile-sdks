//
//  DebugLogStore.swift
//  Parra
//
//  Created by Mick MacCallum on 3/28/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

final class DebugLogStore: ObservableObject {
    struct UniqueLog: Identifiable {
        let id: String
        let message: String
        let timestamp: String
    }

    static let shared = DebugLogStore()

    @Published var logs: [UniqueLog] = []

    @MainActor
    func write(_ message: String) {
        if logs.count > 500 {
            logs = Array(logs.prefix(500))
        }

        let timestamp = ParraInternal.Constants.Formatters.iso8601Formatter
            .string(
                from: .now
            )

        let log = UniqueLog(
            id: UUID().uuidString,
            message: message,
            timestamp: timestamp
        )

        logs.append(log)
    }
}
