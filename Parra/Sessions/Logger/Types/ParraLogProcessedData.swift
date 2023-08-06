//
//  ParraLogProcessedData.swift
//  Parra
//
//  Created by Mick MacCallum on 7/8/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation

internal struct ParraLogProcessedData {
    let level: ParraLogLevel
    let context: ParraLoggerContext?
    let message: String
    let extra: [String : Any]

    // Differs from the module/filenames in the context. Those could be from
    // where a Logger instance was created. These will be from where the final
    // log call was made.
    let callSiteModule: String
    let callSiteFileName: String
    let callSiteFunction: String
    let callSiteLine: Int
    let callSiteColumn: Int

    let threadInfo: ParraLoggerThreadInfo

    init(logData: ParraLogData) {
        var extra = logData.extra?() ?? [:]

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

        let (module, file) = LoggerHelpers.splitFileId(
            fileId: logData.callSiteContext.fileId
        )
        callSiteFunction = logData.callSiteContext.function
        callSiteLine = logData.callSiteContext.line
        callSiteColumn = logData.callSiteContext.column

        if let extraError = logData.extraError() {
            let errorWithExtra = LoggerHelpers.extractMessageAndExtra(
                from: extraError
            )

            extra["extra_error_description"] = errorWithExtra.message
            extra["extra_error"] = errorWithExtra.extra
        }

        var threadInfo = logData.threadInfo
        threadInfo.demangleCallStack()

        self.level = logData.level
        self.context = logData.context
        self.message = message
        self.extra = extra
        self.callSiteModule = module
        self.callSiteFileName = file
        self.threadInfo = threadInfo
    }
}
