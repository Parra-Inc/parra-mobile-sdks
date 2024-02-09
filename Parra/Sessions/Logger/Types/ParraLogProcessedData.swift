//
//  ParraLogProcessedData.swift
//  Parra
//
//  Created by Mick MacCallum on 7/8/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation

struct ParraLogProcessedData {
    // MARK: - Lifecycle

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

    // MARK: - Internal

    let level: ParraLogLevel
    let extra: [String: Any]?

    // Differs from the module/filenames in the context. Those could be from
    // where a Logger instance was created. These will be from where the final
    // log call was made.
    let callSiteContext: ParraLoggerCallSiteContext
    let loggerContext: ParraLoggerContext?

    let subsystem: String
    let category: String
    let message: String
    let timestamp: Date

    // MARK: - Private

    private static func mergeAllExtras(
        callSiteExtra: [String: Any]?,
        loggerExtra: [String: Any]?,
        errorWithExtra: ParraErrorWithExtra?
    ) -> [String: Any]? {
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
        let callingFunctionName = logContext.callSiteContext.function

        guard let loggerContext = logContext.loggerContext else {
            // There is no data other than the call site function. No point in building
            // a single element category array and joining back to a string.
            return callingFunctionName
        }

        var categoryComponents = [String]()

        if let category = loggerContext.category {
            categoryComponents.append(category)
        }

        if !loggerContext.scopes.isEmpty {
            var scopes = loggerContext.scopes

            // If there isn't a last element to pop, mapping the scopes wouldn't
            // do anything anyway.
            if let last = scopes.popLast() {
                // Scoped logger in a function uses the function name as a scope. We need to associate
                // both that function scope, and the function that the log was created from in the
                // case where they aren't the same.

                switch last {
                case .customName:
                    // The scope wasn't a function. Put it back.
                    scopes.append(last)

                    categoryComponents.append(
                        contentsOf: scopes.map(\.name)
                    )

                    categoryComponents.append(callingFunctionName)
                case .function(let rawName):
                    categoryComponents.append(
                        contentsOf: scopes.map(\.name)
                    )

                    // Logs that occur within a scoped logger that haven't exited
                    // its scope will have a call site function that matches the
                    // most recent scope. If this happens, we drop the last scope
                    // in favor of the call site function formatting. If the logger
                    // exited the original scope, apply special formating to indicate
                    // that this occurred.
                    if rawName == callingFunctionName {
                        categoryComponents.append(callingFunctionName)
                    } else {
                        categoryComponents.append(
                            "\(last.name) -> \(callingFunctionName)"
                        )
                    }
                }
            } else {
                categoryComponents.append(callingFunctionName)
            }
        }

        return categoryComponents.joined(separator: "/")
    }
}
