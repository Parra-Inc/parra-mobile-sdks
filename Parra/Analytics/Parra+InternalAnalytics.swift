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
        fileId: String = #fileID
    ) {
        Task {
            await sessionManager.log(
                event: ParraEventWrapper(event: event, extraParams: params),
                fileId: fileId
            )
        }
    }
}
