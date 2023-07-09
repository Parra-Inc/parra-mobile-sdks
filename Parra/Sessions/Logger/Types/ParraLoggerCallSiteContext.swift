//
//  ParraLoggerCallSiteContext.swift
//  Parra
//
//  Created by Mick MacCallum on 7/6/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation

public typealias ParraLoggerCallSiteContext = (
    // fileId is used in place of Swift < 5.8 #file or #filePath to not
    // expose sensitive information from full file paths.
    fileId: String,
    function: String,
    line: Int,
    column: Int
)
