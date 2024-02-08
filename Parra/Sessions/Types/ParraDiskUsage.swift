//
//  ParraDiskUsage.swift
//  Parra
//
//  Created by Mick MacCallum on 7/8/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation

struct ParraDiskUsage {
    // MARK: Lifecycle

    init?(resourceValues: URLResourceValues) {
        guard let totalCapacity = resourceValues.volumeTotalCapacity,
              let availableCapacity = resourceValues.volumeAvailableCapacity,
              let availableEssentialCapacity = resourceValues
              .volumeAvailableCapacityForImportantUsage,
              let availableOpportunisticCapacity = resourceValues
              .volumeAvailableCapacityForOpportunisticUsage else
        {
            return nil
        }

        self.totalCapacity = totalCapacity
        self.availableCapacity = availableCapacity
        self.availableEssentialCapacity = availableEssentialCapacity
        self.availableOpportunisticCapacity = availableOpportunisticCapacity
    }

    // MARK: Internal

    let totalCapacity: Int
    let availableCapacity: Int

    // Capacity for storing essential resources
    let availableEssentialCapacity: Int64

    // Capacity for storing non-essential resources
    let availableOpportunisticCapacity: Int64
}
