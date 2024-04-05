//
//  ParraDiskUsage+ParraSessionParamDictionaryConvertible.swift
//  Parra
//
//  Created by Mick MacCallum on 7/8/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation

extension ParraDiskUsage: ParraSanitizedDictionaryConvertible {
    var sanitized: ParraSanitizedDictionary {
        return [
            "total_capacity": totalCapacity,
            "available_capacity": availableCapacity,
            "available_essential_capacity": availableEssentialCapacity,
            "available_opportunistic_capacity": availableOpportunisticCapacity
        ]
    }
}
