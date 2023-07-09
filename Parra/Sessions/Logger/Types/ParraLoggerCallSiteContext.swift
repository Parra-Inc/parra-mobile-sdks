//
//  ParraLoggerCallSiteContext.swift
//  Parra
//
//  Created by Mick MacCallum on 7/6/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation

public typealias ParraLoggerCallSiteContext = (
    fileId: String,
//    fileName: String,
    function: String,
    line: Int,
    column: Int
)
