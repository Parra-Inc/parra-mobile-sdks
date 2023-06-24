//
//  SyncState.swift
//  ParraCore
//
//  Created by Mick MacCallum on 6/24/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation

@globalActor
internal struct SyncState {
    internal static let shared = State()

    internal actor State {
        /// Whether or not a sync operation is in progress.
        private var syncing = false

        fileprivate init() {}

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
}
