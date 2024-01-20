//
//  ParraSessionEventTarget.swift
//  Parra
//
//  Created by Mick MacCallum on 8/30/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation

internal enum ParraSessionEventTarget {
    /// Write to all event targets (console and session currently) with the exception of
    /// log events that explicitly bypass being written to sessions.
    case all
    
    /// The indended default behavior. Scheme/user config dependent.
    case automatic

    /// Only write events to the console.
    case console

    /// Only write events to the user's session.
    case session

    /// Events won't be written anywhere.
    case none
}
