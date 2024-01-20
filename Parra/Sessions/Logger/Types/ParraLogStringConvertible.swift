//
//  ParraLogStringConvertible.swift
//  Parra
//
//  Created by Mick MacCallum on 7/8/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation

/// An alternative to CustomStringConvertible that serves the same purpose,
/// but is intended to prevent the inadvertent changing of strings sent to the
/// logger over time, since this shouldn't be used outside of the Logger
/// unlike CustomStringConvertible.
internal protocol ParraLogStringConvertible {
    var loggerDescription: String { get }
}
