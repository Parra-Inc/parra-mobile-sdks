//
//  ParraDictionaryConvertible.swift
//  Parra
//
//  Created by Mick MacCallum on 7/8/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation

internal protocol ParraDictionaryConvertible {
    /// Any additional data that you would like to attach to the event. Useful for filtering and
    /// viewing additional context about users producing the event in the dashboard.
    var dictionary: [String : Any] { get }
}

internal extension ParraDictionaryConvertible {
    var dictionary: [String : Any] {
        return [:]
    }
}
