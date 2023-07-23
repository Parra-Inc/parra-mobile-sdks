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
    let fileId: String
    let function: String
    let line: Int
    let column: Int

    init(
        fileId: String,
        function: String,
        line: Int,
        column: Int
    ) {
        self.fileId = fileId
        self.function = function
        self.line = line
        self.column = column
    }
}
