//
//  Logger.swift
//  Parra
//
//  Created by Mick MacCallum on 7/5/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation

public class Logger {
    public static var loggerBackend: ParraLoggerBackend?

    public let context: ParraLoggerContext
    public private(set) weak var parent: Logger?

    public init(
        category: String? = nil,
        fileId: String = #fileID
    ) {
        if let category {
            context = ParraLoggerContext(
                fileId: fileId,
                categories: [category]
            )
        } else {
            context = ParraLoggerContext(
                fileId: fileId,
                categories: []
            )
        }
    }

    internal init(
        parent: Logger,
        context: ParraLoggerContext
    ) {
        self.context = context
        self.parent = parent
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
            context: self.context,
            message: message,
            extraError: extraError,
            extra: extra,
            callSiteContext: callSiteContext,
            threadInfo: threadInfo
        )

        return ParraLogMarker(
            context: self.context,
            startingContext: callSiteContext
        )
    }

    internal static func logToBackend(
        level: ParraLogLevel,
        message: ParraLazyLogParam,
        context: ParraLoggerContext? = nil,
        extraError: @escaping () -> Error? = { nil },
        extra: @escaping () -> [String: Any]? = { nil },
        callSiteContext: ParraLoggerCallSiteContext,
        threadInfo: ParraLoggerThreadInfo
    ) -> ParraLogMarker {
        // TODO: If logger backend isn't configured yet, check env config, apply format, print to console outside of session events.
        loggerBackend?.log(
            level: level,
            context: nil,
            message: message,
            extraError: extraError,
            extra: extra,
            callSiteContext: callSiteContext,
            threadInfo: threadInfo
        )

        return ParraLogMarker(
            context: context,
            startingContext: callSiteContext
        )
    }
}
