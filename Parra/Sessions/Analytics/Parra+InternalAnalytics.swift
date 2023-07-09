//
//  Parra+InternalAnalytics.swift
//  Parra
//
//  Created by Mick MacCallum on 6/25/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation

internal extension Parra {
    func logEvent(
        _ event: ParraInternalEvent,
        params: [String: Any] = [:],
        _ callSiteContext: ParraLoggerCallSiteContext = (
            fileId: #fileID,
            function: #function,
            line: #line,
            column: #column
        )
    ) {
        sessionManager.writeEvent(
            event: ParraEventWrapper(
                event: event,
                extraParams: params
            ),
            callSiteContext: callSiteContext
        )
    }
}
