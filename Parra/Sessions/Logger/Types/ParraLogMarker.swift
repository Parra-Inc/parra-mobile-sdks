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
    public let category: String?

    internal let startingContext: ParraLoggerCallSiteContext

    internal init(
        date: Date = Date(),
        category: String?,
        startingContext: ParraLoggerCallSiteContext = (
            fileId: #fileID,
            function: #function,
            line: #line,
            column: #column
        )
    ) {
        self.date = date
        self.category = category
        self.startingContext = startingContext
    }
}
