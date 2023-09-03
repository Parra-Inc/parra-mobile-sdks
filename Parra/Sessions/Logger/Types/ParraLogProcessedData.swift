//
//  ParraLogProcessedData.swift
//  Parra
//
//  Created by Mick MacCallum on 7/8/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation

// TODO: This needs a major overhaul. It should take in all the message/level/context/etc
// and essentially only output what is needed to finally send a message to the console.
// Like OSLogLevel, message as a string, etc.

internal struct ParraLogProcessedData {
    internal let level: ParraLogLevel
    internal let extra: [String : Any]?

    // Differs from the module/filenames in the context. Those could be from
    // where a Logger instance was created. These will be from where the final
    // log call was made.
    internal let callSiteContext: ParraLoggerCallSiteContext
    internal let loggerContext: ParraLoggerContext?

    internal let subsystem: String
    internal let category: String
    internal let message: String
    internal let timestamp: Date

    init(logData: ParraLogData) {
        let message: String
        let errorWithExtra: ParraErrorWithExtra?

        switch logData.message {
        case .string(let messageProvider):
            message = messageProvider()

            // If a message string is provided, an extra error may be included as well.
            // This field is not present when the message type is error.
            if let extraError = logData.extraError {
                errorWithExtra = LoggerHelpers.extractMessageAndExtra(
                    from: extraError
                )
            } else {
                errorWithExtra = nil
            }
        case .error(let errorProvider):
            let extracted = LoggerHelpers.extractMessageAndExtra(
                from: errorProvider()
            )

            message = extracted.message

            errorWithExtra = extracted
        }

        let logContext = logData.logContext
        let loggerContext = logContext.loggerContext
        var callSiteContext = logContext.callSiteContext

        if logData.level.requiresStackTraceCapture {
            callSiteContext.threadInfo.demangleCallStack()
        }

        self.subsystem = callSiteContext.fileId
        self.category = ParraLogProcessedData.createCategory(
            logContext: logContext
        )
        self.level = logData.level
        self.timestamp = logData.timestamp
        self.loggerContext = loggerContext
        self.message = message
        self.callSiteContext = callSiteContext
        self.extra = ParraLogProcessedData.mergeAllExtras(
            callSiteExtra: logData.extra,
            loggerExtra: loggerContext?.extra,
            errorWithExtra: errorWithExtra
        )
    }

    private static func mergeAllExtras(
        callSiteExtra: [String : Any]?,
        loggerExtra: [String : Any]?,
        errorWithExtra: ParraErrorWithExtra?
    ) -> [String : Any]? {

        var combinedExtra = loggerExtra ?? [:]

        if let errorWithExtra {
            var errorExtra = errorWithExtra.extra ?? [:]
            errorExtra["$message"] = errorWithExtra.message

            combinedExtra["$error"] = errorExtra
        }

        if let callSiteExtra {
            combinedExtra.merge(callSiteExtra) { $1 }
        }

        return combinedExtra
    }

    private static func createCategory(
        logContext: ParraLogContext
    ) -> String {
        var categoryComponents = [String]()
        if let loggerContext = logContext.loggerContext {
            if let category = loggerContext.category {
                categoryComponents.append(category)
            }

            if !loggerContext.scopes.isEmpty {
                categoryComponents.append(
                    contentsOf: loggerContext.scopes.map { $0.name }
                )
            }
        }

        categoryComponents.append(
            logContext.callSiteContext.function
        )

        return categoryComponents.joined(separator: "/")
    }
}
