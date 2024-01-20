//
//  ParraLoggerTimestampStyle.swift
//  Parra
//
//  Created by Mick MacCallum on 7/8/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation

// TODO: Document samples of each

public enum ParraLoggerTimestampStyle {
    public static let `default` = ParraLoggerTimestampStyle.iso8601

    case custom(DateFormatter)
    case epoch
    case iso8601
    case rfc3339
}
