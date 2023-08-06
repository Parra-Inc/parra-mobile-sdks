//
//  ParraLogMarker.swift
//  Parra
//
//  Created by Mick MacCallum on 7/6/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation

// TODO: Should this just be any event?
public struct ParraLogMarker {
    public let date: Date
    public let initialLevel: ParraLogLevel

    internal let initialContext: ParraLoggerContext?
    internal let message: ParraLazyLogParam
    internal let initialCallSiteContext: ParraLoggerCallSiteContext

    internal init(
        initialLevel: ParraLogLevel,
        message: ParraLazyLogParam,
        initialCallSiteContext: ParraLoggerCallSiteContext,
        context: ParraLoggerContext? = nil,
        date: Date = .now
    ) {
        self.initialLevel = initialLevel
        self.message = message
        self.initialCallSiteContext = initialCallSiteContext
        self.initialContext = context
        self.date = date
    }
}
