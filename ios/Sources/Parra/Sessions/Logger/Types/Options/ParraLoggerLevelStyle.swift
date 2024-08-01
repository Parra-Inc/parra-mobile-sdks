//
//  ParraLoggerLevelStyle.swift
//  Parra
//
//  Created by Mick MacCallum on 7/8/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation

public enum ParraLoggerLevelStyle {
    case symbol
    case word
    case both

    // MARK: - Public

    public static let `default` = ParraLoggerLevelStyle.both
}
