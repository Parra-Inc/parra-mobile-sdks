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
    internal let message: String
    internal let extra: [String : Any]

    // Differs from the module/filenames in the context. Those could be from
    // where a Logger instance was created. These will be from where the final
    // log call was made.
    internal let callSiteModule: String
    internal let callSiteFileName: String
    internal let callSiteFileExtension: String?
    internal let callSiteFunction: String
    internal let callSiteLine: Int
    internal let callSiteColumn: Int

    internal let loggerContext: ParraLoggerContext?

    internal let threadInfo: ParraLoggerThreadInfo

    init(logData: ParraLogData) {
        var extra = logData.extra ?? [:]

        let message: String
        switch logData.message {
        case .string(let messageProvider):
            message = messageProvider()
        case .error(let errorProvider):
            let errorWithExtra = LoggerHelpers.extractMessageAndExtra(
                from: errorProvider()
            )

            message = errorWithExtra.message
            if !errorWithExtra.extra.isEmpty {
                extra["error_extra"] = errorWithExtra.extra
            }
        }

        let logContext = logData.logContext
        let callSiteContext = logContext.callSiteContext

        let (module, fileName, fileExtension) = LoggerHelpers.splitFileId(
            fileId: callSiteContext.fileId
        )
        callSiteModule = module
        callSiteFileName = fileName
        callSiteFileExtension = fileExtension
        callSiteFunction = callSiteContext.function
        callSiteLine = callSiteContext.line
        callSiteColumn = callSiteContext.column

        if let extraError = logData.extraError {
            let errorWithExtra = LoggerHelpers.extractMessageAndExtra(
                from: extraError
            )

            extra["extra_error_description"] = errorWithExtra.message
            extra["extra_error"] = errorWithExtra.extra
        }

        var threadInfo = callSiteContext.threadInfo
        if logData.level.requiresStackTraceCapture {
            threadInfo.demangleCallStack()
        }

        self.level = logData.level
        self.loggerContext = logContext.loggerContext
        self.message = message
        self.extra = extra
        self.threadInfo = threadInfo
    }
}
