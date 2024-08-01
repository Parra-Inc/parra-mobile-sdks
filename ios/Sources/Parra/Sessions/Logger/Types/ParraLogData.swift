//
//  ParraLogData.swift
//  Parra
//
//  Created by Mick MacCallum on 7/8/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation

// TODO: Define and impose length limits for keys/values.

struct ParraLogData {
    let timestamp: Date

    let level: ParraLogLevel

    /// Messages should always be functions that return a message. This allows the logger
    /// to only execute potentially expensive code if the logger is enabled. A wrapper object
    /// is provided to help differentiate between log types.
    let message: ParraLazyLogParam

    /// When a primary message is provided but there is still an error object attached to the log.
    let extraError: Error?

    /// Any additional information that you're like to attach to the log.
    let extra: [String: Any]?

    let logContext: ParraLogContext
}
