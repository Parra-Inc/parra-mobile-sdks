//
//  URL+diskUsage.swift
//  Parra
//
//  Created by Mick MacCallum on 7/8/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation

extension URL {
    static func currentDiskUsage() -> ParraDiskUsage? {
        do {
            let resourceValues = try ParraDataManager.Base.documentDirectory
                .resourceValues(
                    forKeys: [
                        .volumeTotalCapacityKey, .volumeAvailableCapacityKey,
                        .volumeAvailableCapacityForImportantUsageKey,
                        .volumeAvailableCapacityForOpportunisticUsageKey
                    ]
                )

            return ParraDiskUsage(resourceValues: resourceValues)
        } catch {
            Logger.error("Error fetching current disk usage", error)

            return nil
        }
    }
}
