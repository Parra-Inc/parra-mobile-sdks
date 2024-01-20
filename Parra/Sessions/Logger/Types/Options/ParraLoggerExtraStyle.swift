//
//  ParraLoggerExtraStyle.swift
//  Parra
//
//  Created by Mick MacCallum on 9/3/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation

public enum ParraLoggerExtraStyle {
    public static let `default` = ParraLoggerExtraStyle.pretty

    // Extra dictionaries are printed using their default ``description``.
    case raw

    // Similar to ``raw``, but will truncate long keys and values
    case condensed

    // Easy to read, lots of whitespace, and indentation between different levels.
    case pretty
}
