//
//  ParraSyncState.swift
//  Parra
//
//  Created by Mick MacCallum on 6/24/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation

internal actor ParraSyncState {
    /// Whether or not a sync operation is in progress.
    private var syncing = false

    internal func isSyncing() -> Bool {
        return syncing
    }

    internal func beginSync() {
        syncing = true
    }

    internal func endSync() {
        syncing = false
    }
}
