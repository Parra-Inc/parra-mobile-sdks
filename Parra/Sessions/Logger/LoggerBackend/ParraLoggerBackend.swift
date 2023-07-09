//
//  ParraLoggerBackend.swift
//  Parra
//
//  Created by Mick MacCallum on 7/6/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation

public protocol ParraLoggerBackend {
    func log(
        level: ParraLogLevel,
        context: ParraLoggerContext?,
        message: ParraLazyLogParam,
        extraError: @escaping () -> Error?,
        extra: @escaping () -> [String: Any]?,
        callSiteContext: ParraLoggerCallSiteContext,
        threadInfo: ParraLoggerThreadInfo
    )
}
