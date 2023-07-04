//
//  ParraFeedbackSyncManager.swift
//  Parra Feedback
//
//  Created by Michael MacCallum on 3/5/22.
//

import Foundation
import UIKit

internal enum ParraSyncMode: String {
    case immediate
    case eventual
}

/// Manager used to facilitate the synchronization of Parra data stored locally with the Parra API.
internal actor ParraSyncManager {
    /// Whether or not new attempts to sync occured while a sync was in progress. Many sync events could be received while a sync
    /// is in progress so we just track whether any happened. If any happen then we will perform a subsequent sync when the original
    /// is completed.
    internal private(set) var enqueuedSyncMode: ParraSyncMode? = nil

    internal let state: ParraState
    internal let syncState: ParraSyncState
    nonisolated internal let syncDelay: TimeInterval

    private let networkManager: ParraNetworkManager
    private let sessionManager: ParraSessionManager
    private let notificationCenter: NotificationCenterType

    @MainActor private var syncTimer: Timer?
    
    internal init(
        state: ParraState,
        syncState: ParraSyncState,
        networkManager: ParraNetworkManager,
        sessionManager: ParraSessionManager,
        notificationCenter: NotificationCenterType,
        syncDelay: TimeInterval = 30.0
    ) {
        self.state = state
        self.syncState = syncState
        self.networkManager = networkManager
        self.sessionManager = sessionManager
        self.notificationCenter = notificationCenter
        self.syncDelay = syncDelay
    }
    
    /// Used to send collected data to the Parra API. Invoked automatically internally, but can be invoked externally as necessary.
    internal func enqueueSync(with mode: ParraSyncMode) async {
        guard await networkManager.getAuthenticationProvider() != nil else {
            parraLogTrace("Skipping \(mode) sync. Authentication provider is unset.")

            return
        }

        guard await hasDataToSync() else {
            parraLogDebug("Skipping \(mode) sync. No sync necessary.")
            return
        }

        parraLogDebug("Enqueuing sync: \(mode)")

        if await syncState.isSyncing() {
            if mode == .immediate {
                parraLogDebug("Sync already in progress. Sync was requested immediately. Will sync again upon current sync completion.")
                
                enqueuedSyncMode = .immediate
            } else {
                parraLogDebug("Sync already in progress. Marking enqued sync.")
                
                if enqueuedSyncMode != .immediate {
                    // An enqueued eventual sync shouldn't override an enqueued immediate sync.
                    enqueuedSyncMode = .eventual
                }
            }
            
            return
        }

        // Should not be awaited. enqueueSync returns when the sync job is added
        // to the queue.
        Task {
            await self.sync()
        }
        
        parraLogDebug("Sync enqued")
    }
    
    private func sync() async {
        await syncState.beginSync()
        
        let syncToken = UUID().uuidString

        await notificationCenter.postAsync(
            name: Parra.syncDidBeginNotification,
            object: self,
            userInfo: [
                Parra.Constants.syncTokenKey: syncToken
            ]
        )

        defer {
            Task {
                await notificationCenter.postAsync(
                    name: Parra.syncDidEndNotification,
                    object: self,
                    userInfo: [
                        Parra.Constants.syncTokenKey: syncToken
                    ]
                )
            }
        }
        
        guard await hasDataToSync() else {
            parraLogDebug("No data available to sync")

            await syncState.endSync()

            return
        }
        
        parraLogDebug("Starting sync")
        
        do {
            try await performSync()

            parraLogTrace("Sync complete")
        } catch let error {
            parraLogError("Error performing sync", error)
            // TODO: Maybe cancel the sync timer, double the countdown then start a new one?
        }

        guard let enqueuedSyncMode else {
            parraLogDebug("No more jobs found. Completing sync.")

            await syncState.endSync()

            return
        }

        parraLogDebug("More sync jobs were enqueued. Repeating sync.")

        self.enqueuedSyncMode = nil

        switch enqueuedSyncMode {
        case .immediate:
            await sync()
        case .eventual:
            await syncState.endSync()
        }
    }

    private func performSync() async throws {
        var syncError: Error?

        // Rethrow after receiving an error for throttling, but allow each module to attempt a sync once
        for (_, module) in await state.getAllRegisteredModules() {
            do {
                try await module.synchronizeData()
            } catch let error {
                syncError = error
            }
        }

        if let syncError {
            throw syncError
        }
    }
    
    private func hasDataToSync() async -> Bool {
        var shouldSync = false
        for (_, module) in await state.getAllRegisteredModules() {
            if await module.hasDataToSync() {
                shouldSync = true
                break
            }
        }
        
        return shouldSync
    }
    
    @MainActor
    internal func startSyncTimer(
        willSyncHandler: (() -> Void)? = nil
    ) {
        stopSyncTimer()
        parraLogTrace("Starting sync timer")

        syncTimer = Timer.scheduledTimer(
            withTimeInterval: syncDelay,
            repeats: true
        ) { timer in
            parraLogTrace("Sync timer fired")

            willSyncHandler?()

            Task {
                await self.enqueueSync(with: .immediate)
            }
        }
    }
    
    @MainActor
    internal func stopSyncTimer() {
        guard let syncTimer = syncTimer else {
            return
        }

        parraLogTrace("Stopping sync timer")

        syncTimer.invalidate()
        self.syncTimer = nil
    }

    @MainActor
    internal func isSyncTimerActive() -> Bool {
        guard let syncTimer else {
            return false
        }

        return syncTimer.isValid
    }
}
