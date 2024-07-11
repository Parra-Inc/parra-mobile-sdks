//
//  ExceptionHandler+CrashInfo.swift
//  Parra
//
//  Created by Mick MacCallum on 7/11/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Foundation

extension ExceptionHandler {
    struct CrashInfo: Codable {
        // MARK: - Lifecycle

        init(
            type: ExceptionHandler.CrashType,
            name: String,
            reason: String,
            callStack: [String]
        ) {
            self.type = type
            self.name = name
            self.reason = reason
            self.callStack = callStack
        }

        // MARK: - Internal

        let type: ExceptionHandler.CrashType
        let name: String
        let reason: String
        let callStack: [String]
    }
}
