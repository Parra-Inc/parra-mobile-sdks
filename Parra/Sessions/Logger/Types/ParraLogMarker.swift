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
    public let context: ParraLoggerContext?

    internal let startingContext: ParraLoggerCallSiteContext

    internal init(
        date: Date = Date(),
        context: ParraLoggerContext? = nil,
        startingContext: ParraLoggerCallSiteContext
    ) {
        self.date = date
        self.context = context
        self.startingContext = startingContext
    }
}
