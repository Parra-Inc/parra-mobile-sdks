//
//  Parra+InternalAnalytics.swift
//  Parra
//
//  Created by Mick MacCallum on 6/25/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation

extension Parra {
    @inlinable
    func logEvent(
        _ event: ParraInternalEvent,
        _ extra: [String: Any],
        _ fileId: String = #fileID,
        _ function: String = #function,
        _ line: Int = #line,
        _ column: Int = #column
    ) {
        let threadInfo = ParraLoggerThreadInfo(
            thread: .current
        )

        sessionManager.writeEvent(
            wrappedEvent: .internalEvent(
                event: event,
                extra: extra
            ),
            callSiteContext: ParraLoggerCallSiteContext(
                fileId: fileId,
                function: function,
                line: line,
                column: column,
                threadInfo: threadInfo
            )
        )
    }

    @inlinable
    func logEvent(
        _ event: ParraInternalEvent,
        _ fileId: String = #fileID,
        _ function: String = #function,
        _ line: Int = #line,
        _ column: Int = #column
    ) {
        let threadInfo = ParraLoggerThreadInfo(
            thread: .current
        )

        sessionManager.writeEvent(
            wrappedEvent: .internalEvent(
                event: event,
                extra: nil
            ),
            callSiteContext: ParraLoggerCallSiteContext(
                fileId: fileId,
                function: function,
                line: line,
                column: column,
                threadInfo: threadInfo
            )
        )
    }
}
