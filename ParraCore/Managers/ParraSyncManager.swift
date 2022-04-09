//
//  ParraFeedbackSyncManager.swift
//  Parra Feedback
//
//  Created by Michael MacCallum on 3/5/22.
//

import Foundation
import UIKit

actor ParraFeedbackSyncManager {
    enum Constant {
        static let syncTokenKey = "syncToken"
    }
    
    private let networkManager: ParraNetworkManager
    
    /// Whether or not a sync operation is in progress.
    internal private(set) var isSyncing = false
    
    /// Whether or not new attempts to sync occured while a sync was in progress. Many sync events could be received while a sync
    /// is in progress so we just track whether any happened. If any happen then we will perform a subsequent sync when the original
    /// is completed.
    internal private(set) var hasEnqueuedSyncJobs = false
    
    init(networkManager: ParraNetworkManager) {
        self.networkManager = networkManager
    }
    
    /// Used to send collected data to the Parra API. Invoked automatically internally, but can be invoked externally as necessary.
    internal func enqueueSync() async {
        parraLogV("Enqueuing sync")

        if isSyncing {
            parraLogV("Sync already in progress. Marking enqued sync.")

            hasEnqueuedSyncJobs = true
            
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
        
        if hasEnqueuedSyncJobs {
            parraLogV("More sync jobs were enqueued. Repeating sync.")
            hasEnqueuedSyncJobs = false
            
            await sync()
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
}
