//
//  ParraLogMarker.swift
//  Parra
//
//  Created by Mick MacCallum on 7/6/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation

public struct ParraLogMarker {
    public let date: Date
    public let initialLevel: ParraLogLevel

    internal let initialLogContext: ParraLogContext
    internal let message: ParraLazyLogParam

    internal init(
        message: ParraLazyLogParam,
        initialLevel: ParraLogLevel,
        initialLogContext: ParraLogContext,
        date: Date = .now
    ) {
        self.date = date
        self.message = message
        self.initialLevel = initialLevel
        self.initialLogContext = initialLogContext
    }
}
