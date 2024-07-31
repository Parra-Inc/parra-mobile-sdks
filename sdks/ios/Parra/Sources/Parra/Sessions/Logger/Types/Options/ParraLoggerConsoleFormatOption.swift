//
//  ParraLoggerConsoleFormatOption.swift
//  Parra
//
//  Created by Mick MacCallum on 7/8/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation

public enum ParraLoggerConsoleFormatOption {
    case printMessage(leftPad: String, rightPad: String)
    case printTimestamps(
        style: ParraLoggerTimestampStyle,
        leftPad: String,
        rightPad: String
    )
    case printLevel(
        style: ParraLoggerLevelStyle,
        leftPad: String,
        rightPad: String
    )
    case printCallSite(
        options: ParraLoggerCallSiteStyleOptions,
        leftPad: String,
        rightPad: String
    )
    case printExtras(
        style: ParraLoggerExtraStyle,
        leftPad: String,
        rightPad: String
    )
}
