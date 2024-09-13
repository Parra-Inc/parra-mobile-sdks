//
//  DebugLogStore.swift
//  Parra
//
//  Created by Mick MacCallum on 3/28/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import CoreTransferable
import SwiftUI

@Observable
final class DebugLogStore {
    struct UniqueLog: Identifiable {
        let id: String
        let message: String
        let timestamp: String
    }

    struct ShareableLogs: Transferable {
        static var transferRepresentation: some TransferRepresentation {
            DataRepresentation(exportedContentType: .log) { object in
                var fileString = ""

                for log in object.logs {
                    fileString.append("\(log.timestamp) \(log.message)\n")
                }

                guard let data = fileString.data(using: .utf8) else {
                    throw ParraError.message(
                        "Failed to encode logs for sharing."
                    )
                }

                return data
            }
        }

        var logs: [UniqueLog]
    }

    static let shared = DebugLogStore()

    var shareableLogs = ShareableLogs(logs: [])

    @MainActor
    func write(_ message: String) {
        if shareableLogs.logs.count > 500 {
            shareableLogs.logs = Array(shareableLogs.logs.prefix(500))
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

        shareableLogs.logs.insert(log, at: 0)
    }
}
