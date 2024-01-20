//
//  ParraLoggerCallSiteStyleOptions.swift
//  Parra
//
//  Created by Mick MacCallum on 7/8/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation

public struct ParraLoggerCallSiteStyleOptions: OptionSet {
    public static let `default`: ParraLoggerCallSiteStyleOptions = [
        .function, .line
    ]

    public let rawValue: Int8

    public static let thread   = ParraLoggerCallSiteStyleOptions(rawValue: 1 << 0)
    public static let function = ParraLoggerCallSiteStyleOptions(rawValue: 1 << 1)
    public static let line     = ParraLoggerCallSiteStyleOptions(rawValue: 1 << 2)
    public static let column   = ParraLoggerCallSiteStyleOptions(rawValue: 1 << 3)

    public init(rawValue: Int8) {
        self.rawValue = rawValue
    }
}
