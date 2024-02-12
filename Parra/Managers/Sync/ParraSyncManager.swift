//
//  ParraSyncManager.swift
//  Parra Feedback
//
//  Created by Michael MacCallum on 3/5/22.
//

import Foundation
import UIKit

// TODO: What happens to the timer when the app goes to the background?
// TODO: Timer should have exponential backoff. New eventual sync enqueued should reset this.

private let logger = Logger(bypassEventCreation: true, category: "Sync Manager")

/// Manager used to facilitate the synchronization of Parra data stored locally with the Parra API.
class ParraSyncManager {
    // MARK: - Lifecycle

    init(
        syncState: ParraSyncState,
        networkManager: ParraNetworkManager,
        sessionManager: ParraSessionManager,
        notificationCenter: NotificationCenterType,
        syncDelay: TimeInterval = 30.0
    ) {
        self.syncState = syncState
        self.networkManager = networkManager
        self.sessionManager = sessionManager
        self.notificationCenter = notificationCenter
        self.syncDelay = syncDelay
    }

    // MARK: - Internal

    weak var delegate: SyncManagerDelegate?

    /// Whether or not new attempts to sync occured while a sync was in progress. Many sync events could be received while a sync
    /// is in progress so we just track whether any happened. If any happen then we will perform a subsequent sync when the original
    /// is completed.
    private(set) var enqueuedSyncMode: ParraSyncMode?

    let syncState: ParraSyncState
    nonisolated let syncDelay: TimeInterval

    /// Used to send collected data to the Parra API. Invoked automatically internally, but can be invoked externally as necessary.
    func enqueueSync(with mode: ParraSyncMode) async {
        guard await networkManager.getAuthenticationProvider() != nil else {
            await stopSyncTimer()
            logger
                .trace(
                    "Skipping \(mode) sync. Authentication provider is unset."
                )

            return
        }

        guard await hasDataToSync(since: lastSyncCompleted) else {
            logger.debug("Skipping \(mode) sync. No sync necessary.")
            return
        }

        logger.debug("Preparing to enqueue sync: \(mode)")

        if await syncState.isSyncing() {
            let logPrefix = "Sync already in progress."
            switch mode {
            case .immediate:
                logger
                    .debug(
                        "\(logPrefix) Sync was requested immediately. Will sync again upon current sync completion."
                    )

                enqueuedSyncMode = .immediate
            case .eventual:
                logger.debug("\(logPrefix) Marking enqued sync.")

                if enqueuedSyncMode != .immediate {
                    // An enqueued eventual sync shouldn't override an enqueued immediate sync.
                    enqueuedSyncMode = .eventual
                }
            }

            return
        }

        let logPrefix = "No sync in progress."
        switch mode {
        case .immediate:
            logger.debug("\(logPrefix) Initiating immediate sync.")
            enqueuedSyncMode = nil
            // Should not be awaited. enqueueSync returns when the sync job is added
            // to the queue.
            Task {
                await self.sync()
            }
        case .eventual:
            enqueuedSyncMode = .eventual
            logger.debug("\(logPrefix) Queuing eventual sync.")

            if await !isSyncTimerActive() {
                await startSyncTimer()
            }
        }
    }

    @MainActor
    func startSyncTimer(
        willSyncHandler: (() -> Void)? = nil
    ) {
        stopSyncTimer()
        logger.trace("Starting sync timer")

        syncTimer = Timer.scheduledTimer(
            withTimeInterval: syncDelay,
            repeats: true
        ) { [weak self] _ in
            guard let self else {
                return
            }

            logger.trace("Sync timer fired")

            willSyncHandler?()

            Task {
                await self.enqueueSync(with: .immediate)
            }
        }
    }

    @MainActor
    func stopSyncTimer() {
        guard let syncTimer else {
            return
        }

        logger.trace("Stopping sync timer")

        syncTimer.invalidate()
        self.syncTimer = nil
    }

    @MainActor
    func isSyncTimerActive() -> Bool {
        guard let syncTimer else {
            return false
        }

        return syncTimer.isValid
    }

    func cancelEnqueuedSyncs() {
        enqueuedSyncMode = nil
    }

    // MARK: - Private

    private let networkManager: ParraNetworkManager
    private let sessionManager: ParraSessionManager
    private let notificationCenter: NotificationCenterType

    @MainActor private var syncTimer: Timer?

    private var lastSyncCompleted: Date?

    private func sync(
        isRepeat: Bool = false
    ) async {
        if !isRepeat {
            if await syncState.isSyncing() {
                logger
                    .warn("Attempted to start a sync while one is in progress.")

                return
            }

            await syncState.beginSync()
        }

        let syncToken = UUID().uuidString

        // This notification is deliberately kept before the check for if
        // there is data to sync.
        await notificationCenter.postAsync(
            name: Parra.syncDidBeginNotification,
            object: self,
            userInfo: [
                Parra.Constants.syncTokenKey: syncToken
            ]
        )

        var shouldRepeatSync = false

        defer {
            lastSyncCompleted = .now

            completeSync(
                token: syncToken,
                shouldRepeat: shouldRepeatSync
            )
        }

        guard await hasDataToSync(since: lastSyncCompleted) else {
            logger.debug("No data available to sync")

            await syncState.endSync()

            return
        }

        let syncStartMarker = logger.debug("Starting sync")

        do {
            try await performSync(with: syncToken)

            logger.measureTime(since: syncStartMarker, message: "Sync complete")
        } catch {
            logger.error("Error performing sync", error)

            if enqueuedSyncMode == .immediate {
                // Try to avoid the case there there might be something wrong with the data
                // being synced that could cause it to fail again if synced immediately.
                // This will at least keep us in a failure loop at the duration of the sync
                // timer.
                logger
                    .debug(
                        "Immediate sync was enqueued after error. Resetting to eventual."
                    )
                enqueuedSyncMode = .eventual
            }

            // TODO: Maybe cancel the sync timer, double the countdown then start a new one?
        }

        guard let enqueuedSyncMode else {
            logger.debug("No more jobs found. Completing sync.")

            await syncState.endSync()

            return
        }

        logger.debug("More sync jobs were enqueued. Repeating sync.")

        self.enqueuedSyncMode = nil

        switch enqueuedSyncMode {
        case .immediate:
            shouldRepeatSync = true
        case .eventual:
            await syncState.endSync()
        }
    }

    private func performSync(
        with token: String
    ) async throws {
        guard let targets = delegate?.getSyncTargets() else {
            logger.debug("sync delegate unset while performing sync")

            return
        }

        guard !targets.isEmpty else {
            logger
                .debug(
                    "sync delegate produced no sync targets while performing sync"
                )

            return
        }

        var syncError: Error?

        // Rethrow after receiving an error for throttling, but allow each module to attempt a sync once
        for target in targets {
            do {
                try await target.synchronizeData()
            } catch {
                syncError = error
            }
        }

        if let syncError {
            throw syncError
        }
    }

    private func completeSync(
        token: String,
        shouldRepeat: Bool
    ) {
        lastSyncCompleted = .now

        Task {
            // Ensure that the notification that the current sync has ended is sent
            // before the next sync begins.
            await notificationCenter.postAsync(
                name: Parra.syncDidEndNotification,
                object: self,
                userInfo: [
                    Parra.Constants.syncTokenKey: token
                ]
            )

            if shouldRepeat {
                // Must be kept inside a Task block to avoid the current sync's
                // completion awaiting the next sync.
                await sync(isRepeat: true)
            }
        }
    }

    private func hasDataToSync(since date: Date?) async -> Bool {
        guard let targets = delegate?.getSyncTargets() else {
            logger.debug("sync delegate unset while checking for sync data")

            return false
        }

        guard !targets.isEmpty else {
            logger
                .debug(
                    "sync delegate produced no sync targets while checking for sync data"
                )

            return false
        }

        var shouldSync = false

        for target in targets {
            if await target.hasDataToSync(since: date) {
                shouldSync = true
                break
            }
        }

        return shouldSync
    }
}
