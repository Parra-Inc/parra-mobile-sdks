//
//  ParraSyncState.swift
//  Parra
//
//  Created by Mick MacCallum on 6/24/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation

actor ParraSyncState {
    // MARK: - Internal

    func isSyncing() -> Bool {
        return syncing
    }

    func beginSync() {
        syncing = true
    }

    func endSync() {
        syncing = false
    }

    // MARK: - Private

    /// Whether or not a sync operation is in progress.
    private var syncing = false
}
