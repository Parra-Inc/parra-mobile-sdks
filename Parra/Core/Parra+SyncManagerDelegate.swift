//
//  Parra+SyncManagerDelegate.swift
//  Parra
//
//  Created by Mick MacCallum on 2/10/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Foundation

extension Parra: SyncManagerDelegate {
    func getSyncTargets() -> [SyncTarget] {
        return [
            // These should be in order of importance of the sync tasks.
            self,
            feedback
        ]
    }
}
