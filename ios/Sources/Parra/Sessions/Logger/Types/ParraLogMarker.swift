//
//  ParraLogMarker.swift
//  Parra
//
//  Created by Mick MacCallum on 7/6/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation

public struct ParraLogMarker {
    // MARK: - Lifecycle

    init(
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

    // MARK: - Public

    public let timestamp: Date
    public let initialLevel: ParraLogLevel

    // MARK: - Internal

    let initialLogContext: ParraLogContext
    let message: ParraLazyLogParam
}
