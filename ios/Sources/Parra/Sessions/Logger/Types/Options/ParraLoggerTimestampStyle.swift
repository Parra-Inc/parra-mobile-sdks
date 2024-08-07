//
//  ParraLoggerTimestampStyle.swift
//  Parra
//
//  Created by Mick MacCallum on 7/8/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation

public enum ParraLoggerTimestampStyle {
    case custom(DateFormatter)
    /// A Unix timestamp representing the number of seconds that have elapsed
    /// since 00:00:00 UTC on 1 January 1970 (excluding leap seconds).
    case epoch

    /// For example: 2021-07-01T00:00:00+00:00
    case iso8601

    /// For example: 2021-10-01T00:00:00.000Z
    case rfc3339

    // MARK: - Public

    public static let `default` = ParraLoggerTimestampStyle.iso8601
}
