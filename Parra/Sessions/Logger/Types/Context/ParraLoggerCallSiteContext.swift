//
//  ParraLoggerCallSiteContext.swift
//  Parra
//
//  Created by Mick MacCallum on 7/6/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation

public struct ParraLoggerCallSiteContext {
    // fileId is used in place of Swift < 5.8 #file or #filePath to not
    // expose sensitive information from full file paths.
    internal let fileId: String
    internal let function: String
    internal let line: Int
    internal let column: Int

    /// Must be passed in from the call site to ensure that information about the correct thread
    /// is captured, and that we don't capture stack frames from within the Parra Logger, thus
    /// potentially omitting important context.
    internal var threadInfo: ParraLoggerThreadInfo

    internal init(
        fileId: String,
        function: String,
        line: Int,
        column: Int,
        threadInfo: ParraLoggerThreadInfo
    ) {
        self.fileId = fileId
        self.function = function
        self.line = line
        self.column = column
        self.threadInfo = threadInfo
    }

    internal var simpleFunctionName: String {
        let components = function.split(separator: "(")

        guard let first = components.first else {
            return function
        }

        return String(first)
    }
}
