//
//  ParraLogProcessedData.swift
//  Parra
//
//  Created by Mick MacCallum on 7/8/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation

internal struct ParraLogProcessedData {
    let date: Date
    let level: ParraLogLevel
    let context: ParraLoggerContext?
    let message: String
    let extra: [String: Any]

    // Differs from the module/filenames in the context. Those could be frome
    // where a Logger instance was created. These will be from where the final
    // log call was made.
    let callSiteModule: String
    let callSiteFileName: String

    let threadInfo: ParraLoggerThreadInfo

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

        let (module, file, _) = LoggerHelpers.splitFileId(
            fileId: logData.callSiteContext.fileId
        )

        var extra = logData.extra() ?? [:]
        if let extraError = logData.extraError() {
            extra["error_description"] = LoggerHelpers.extractMessage(
                from: extraError
            )
        }

        self.date = logData.date
        self.level = logData.level
        self.context = logData.context
        self.message = message
        self.extra = extra
        self.callSiteModule = module
        self.callSiteFileName = file
        self.threadInfo = logData.threadInfo
    }
}