//
//  ExceptionHandler+CrashInfo.swift
//  Parra
//
//  Created by Mick MacCallum on 7/11/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Foundation

extension ExceptionHandler {
    struct CrashInfo: Codable, Hashable {
        // MARK: - Lifecycle

        init(
            sessionId: String?,
            type: ExceptionHandler.CrashType,
            name: String,
            reason: String,
            callStack: [String],
            timestamp: TimeInterval = Date().timeIntervalSince1970
        ) {
            self.sessionId = sessionId
            self.type = type
            self.name = name
            self.reason = reason
            self.callStack = callStack
            self.timestamp = timestamp
        }

        // MARK: - Internal

        let sessionId: String?
        let type: ExceptionHandler.CrashType
        let name: String
        let reason: String
        let callStack: [String]
        let timestamp: TimeInterval
    }
}
