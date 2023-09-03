//
//  ParraLogMarker.swift
//  Parra
//
//  Created by Mick MacCallum on 7/6/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation

public struct ParraLogMarker {
    public let timestamp: Date
    public let initialLevel: ParraLogLevel

    internal let initialLogContext: ParraLogContext
    internal let message: ParraLazyLogParam

    internal init(
        timestamp: Date,
        message: ParraLazyLogParam,
        initialLevel: ParraLogLevel,
        initialLogContext: ParraLogContext
    ) {
        self.timestamp = timestamp
        self.message = message
        self.initialLevel = initialLevel
        self.initialLogContext = initialLogContext
    }
}
