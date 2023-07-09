//
//  ParraLogData.swift
//  Parra
//
//  Created by Mick MacCallum on 7/8/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation

// TODO: Define and impose length limits for keys/values.

internal struct ParraLogData {
    let level: ParraLogLevel
    let category: String?
    let subsystem: String
    let file: String

    /// Messages should always be functions that return a message. This allows the logger
    /// to only execute potentially expensive code if the logger is enabled. A wrapper object
    /// is provided to help differentiate between log types.
    let message: ParraLazyLogParam

    /// When a primary message is provided but there is still an error object attached to the log.
    let extraError: () -> Error?

    /// Any additional information that you're like to attach to the log.
    let extra: () -> [String: Any]?

    let callSiteContext: ParraLoggerCallSiteContext

    /// Must be passed in from the call site to ensure that information about the correct thread
    /// is captured, and that we don't capture stack frames from within the Parra Logger, thus
    /// potentially omitting important context.
    let threadInfo: ParraLoggerThreadInfo
}

internal struct ParraProcessedLogData {
//    let level: ParraLogLevel
//    let category: String?
//    let subsystem: String
//    let file: String
    let message: String

    init(logData: ParraLogData) {
        let message: String
        switch logData.message {
        case .string(let messageProvider):
            message = messageProvider()
        case .error(let errorProvider):
            message = LoggerHelpers.extractMessage(
                from: errorProvider()
            )
        }

        self.message = message
    }
}

extension ParraLogData: ParraSessionParamDictionaryConvertible {
    var paramDictionary: [String : Any] {
        return [:]
//        return [
//            "message":
//        ]
    }
}

//static let eventPrefix = "parra:logger:"
//
//static let eventMessageKey = "\(eventPrefix)message"
//static let eventLevelKey = "\(eventPrefix)level"
//static let eventTimestampKey = "\(eventPrefix)timestamp"
//static let eventFileKey = "\(eventPrefix)file"
//static let eventModuleKey = "\(eventPrefix)module"
//static let eventThreadKey = "\(eventPrefix)thread"
//static let eventThreadIdKey = "\(eventPrefix)threadId"
//static let eventExtraKey = "\(eventPrefix)extra"
//static let eventCallStackKey = "\(eventPrefix)stack"
