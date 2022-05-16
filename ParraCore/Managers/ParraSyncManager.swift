//
//  ParraFeedbackSyncManager.swift
//  Parra Feedback
//
//  Created by Michael MacCallum on 3/5/22.
//

import Foundation
import UIKit

enum ParraFeedbackSyncMode: String {
    case immediate
    case eventual
}

/// Manager used to facilitate the synchronization of Parra data stored locally with the Parra API.
class ParraFeedbackSyncManager {
    enum Constant {
        static let syncTokenKey = "syncToken"
        static let eventualSyncDelay: TimeInterval = 30.0
    }
        
    /// Whether or not a sync operation is in progress.
    internal private(set) var isSyncing = false
    
    /// Whether or not new attempts to sync occured while a sync was in progress. Many sync events could be received while a sync
    /// is in progress so we just track whether any happened. If any happen then we will perform a subsequent sync when the original
    /// is completed.
    internal private(set) var enqueuedSyncMode: ParraFeedbackSyncMode? = nil
    
    private let networkManager: ParraNetworkManager

    private var syncTimer: Timer?
    
    init(networkManager: ParraNetworkManager) {
        self.networkManager = networkManager
    }
    
    /// Used to send collected data to the Parra API. Invoked automatically internally, but can be invoked externally as necessary.
    internal func enqueueSync(with mode: ParraFeedbackSyncMode) async {
        parraLogV("Enqueuing sync: \(mode)")

        if isSyncing {
            if mode == .immediate {
                parraLogV("Sync already in progress. Sync was requested immediately. Will sync again upon current sync completion.")

                enqueuedSyncMode = .immediate
            } else {
                parraLogV("Sync already in progress. Marking enqued sync.")
                
                if enqueuedSyncMode != .immediate {
                    // An enqueued eventual sync shouldn't override an enqueued immediate sync.
                    enqueuedSyncMode = .eventual
                }
            }
            
            return
        }
        
        Task {
            await self.sync()
        }

        parraLogV("Sync enqued")
    }
    
    private func sync() async {
        isSyncing = true
        
        let syncToken = UUID().uuidString
        
        NotificationCenter.default.post(
            name: Parra.syncDidBeginNotification,
            object: self,
            userInfo: [
                Constant.syncTokenKey: syncToken
            ]
        )
        
        defer {
            NotificationCenter.default.post(
                name: Parra.syncDidEndNotification,
                object: self,
                userInfo: [
                    Constant.syncTokenKey: syncToken
                ]
            )
        }
        
        guard await hasDataToSync() else {
            parraLogV("No data available to sync")
            isSyncing = false

            return
        }
        
        parraLogV("Starting sync")

        let start = CFAbsoluteTimeGetCurrent()
        parraLogV("Sending sync data...")
        
        for (_, module) in Parra.registeredModules {
            await module.triggerSync()
        }

        let duration = CFAbsoluteTimeGetCurrent() - start
        parraLogV("Sync data sent. Took \(duration)(s)")
        
        if let enqueuedSyncMode = enqueuedSyncMode {
            parraLogV("More sync jobs were enqueued. Repeating sync.")
            
            self.enqueuedSyncMode = nil
            
            switch enqueuedSyncMode {
            case .immediate:
                await sync()
            case .eventual:
                startSyncTimer()
            }
        } else {
            parraLogV("No more jobs found. Completing sync.")

            isSyncing = false
        }
    }
    
    private func hasDataToSync() async -> Bool {
        var shouldSync = false
        
        for (_, module) in Parra.registeredModules {
            if await module.hasDataToSync() {
                shouldSync = true
                break
            }
        }
        
        return shouldSync
    }
    
    private func startSyncTimer() {
        stopSyncTimer()
    
        syncTimer = Timer.scheduledTimer(
            timeInterval: Constant.eventualSyncDelay,
            target: self,
            selector: #selector(syncTimerDidTick),
            userInfo: nil,
            repeats: false
        )
    }
        
    private func stopSyncTimer() {
        guard let syncTimer = syncTimer else {
            return
        }

        syncTimer.invalidate()
        self.syncTimer = nil
    }
    
    @objc private func syncTimerDidTick() {
        stopSyncTimer()

        Task {
            await self.enqueueSync(with: .immediate)
        }
    }
}
