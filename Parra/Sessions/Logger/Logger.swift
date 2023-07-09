//
//  Logger.swift
//  Parra
//
//  Created by Mick MacCallum on 7/5/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation

public struct Logger {
    public static var loggerBackend: ParraLoggerBackend?

    let subsystem: String
    let file: String
    let category: String?

    public init(
        category: String?,
        subsystem: String? = nil,
        file: String? = nil,
        _ callSiteContext: ParraLoggerCallSiteContext = (
            fileId: #fileID,
            function: #function,
            line: #line,
            column: #column
        )
    ) {
        let (module, fileName, _) = LoggerHelpers.splitFileId(
            fileId: callSiteContext.fileId
        )

        self.subsystem = subsystem ?? module
        self.file = file ?? fileName
        self.category = category
    }

    public init(
        category: String?,
        _ callSiteContext: ParraLoggerCallSiteContext = (
            fileId: #fileID,
            function: #function,
            line: #line,
            column: #column
        )
    ) {
        let (module, fileName, _) = LoggerHelpers.splitFileId(
            fileId: callSiteContext.fileId
        )

        self.subsystem = module
        self.file = fileName
        self.category = category
    }

    internal func logToBackend(
        level: ParraLogLevel,
        message: ParraLazyLogParam,
        extraError: @escaping () -> Error? = { nil },
        extra: @escaping () -> [String: Any]? = { nil },
        callSiteContext: ParraLoggerCallSiteContext,
        threadInfo: ParraLoggerThreadInfo
    ) -> ParraLogMarker {
        Logger.loggerBackend?.log(
            level: level,
            category: category,
            subsystem: subsystem,
            file: file,
            message: message,
            extraError: extraError,
            extra: extra,
            callSiteContext: callSiteContext,
            threadInfo: threadInfo
        )

        return ParraLogMarker(
            category: category,
            startingContext: callSiteContext
        )
    }

    internal static func logToBackend(
        level: ParraLogLevel,
        category: String? = nil,
        message: ParraLazyLogParam,
        extraError: @escaping () -> Error? = { nil },
        extra: @escaping () -> [String: Any]? = { nil },
        callSiteContext: ParraLoggerCallSiteContext,
        threadInfo: ParraLoggerThreadInfo
    ) -> ParraLogMarker {
        let (module, fileName, _) = LoggerHelpers.splitFileId(
            fileId: callSiteContext.fileId
        )

        // TODO: If logger backend isn't configured yet, check env config, apply format, print to console outside of session events.
        loggerBackend?.log(
            level: level,
            category: category,
            subsystem: module,
            file: fileName,
            message: message,
            extraError: extraError,
            extra: extra,
            callSiteContext: callSiteContext,
            threadInfo: threadInfo
        )

        return ParraLogMarker(
            category: category,
            startingContext: callSiteContext
        )
    }
}
