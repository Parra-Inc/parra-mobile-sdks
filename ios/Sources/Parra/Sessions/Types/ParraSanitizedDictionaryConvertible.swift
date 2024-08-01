//
//  ParraSanitizedDictionaryConvertible.swift
//  Parra
//
//  Created by Mick MacCallum on 7/8/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation

/// A helper for obtaining a dictionary representation of any conforming types. It is used
/// in places where the data returned may be logged, so any conforming type is expected to
/// return data that has been stripped of sensitive information from the ``sanitized`` property.
protocol ParraSanitizedDictionaryConvertible {
    /// Any additional data that you would like to attach to the event. Useful for filtering and
    /// viewing additional context about users producing the event in the dashboard.
    var sanitized: ParraSanitizedDictionary { get }
}

extension ParraSanitizedDictionaryConvertible {
    var sanitized: ParraSanitizedDictionary {
        return [:]
    }
}
