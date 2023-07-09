//
//  ParraLoggerConsoleFormatOption.swift
//  Parra
//
//  Created by Mick MacCallum on 7/8/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation

public enum ParraLoggerConsoleFormatOption {
    case printTimestamps(style: ParraLoggerTimestampStyle)
    case printLevel(style: ParraLoggerLevelStyle)
    case printCallSite(options: ParraLoggerCallSiteStyleOptions)
    case printExtras
}
