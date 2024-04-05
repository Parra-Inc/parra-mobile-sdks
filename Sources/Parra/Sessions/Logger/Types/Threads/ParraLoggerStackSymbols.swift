//
//  ParraLoggerStackSymbols.swift
//  Parra
//
//  Created by Mick MacCallum on 9/3/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation

@usableFromInline
enum ParraLoggerStackSymbols: Codable {
    case raw([String])
    case demangled([CallStackFrame])
    case none
}
