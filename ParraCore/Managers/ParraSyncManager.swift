//
//  ParraFeedbackSyncManager.swift
//  Parra Feedback
//
//  Created by Michael MacCallum on 3/5/22.
//

import Foundation
import UIKit

actor ParraFeedbackSyncManager {
    private let networkManager: ParraNetworkManager
    
    /// Whether or not a sync operation is in progress.
    private var isSyncing = false
    
    /// Whether or not new attempts to sync occured while a sync was in progress. Many sync events could be received while a sync
    /// is in progress so we just track whether any happened. If any happen then we will perform a subsequent sync when the original
    /// is completed.
    private var hasEnqueuedSyncJobs = false
    
    init(networkManager: ParraNetworkManager) {
        self.networkManager = networkManager
    }
    
    /// Used to send collected data to the Parra API. Invoked automatically internally, but can be invoked externally as necessary.
    internal func enqueueSync() {
        parraLogV("Enqueuing sync")

        if isSyncing {
            parraLogV("Sync already in progress. Marking enqued sync.")

            hasEnqueuedSyncJobs = true
            
            return
        }
        
        Task {
            await self.sync()
            
            parraLogV("Sync complete")
        }
    }
    
    private func sync() async {
        guard await hasDataToSync() else {
            parraLogV("No data available to sync")

            return
        }
        
        parraLogV("Starting sync")

        defer {
            if hasEnqueuedSyncJobs {
                parraLogV("More sync jobs were enqueued. Repeating sync.")
                hasEnqueuedSyncJobs = false
                
                Task {
                    await self.sync()
                }
            } else {
                parraLogV("No more jobs found. Completing sync.")

                isSyncing = false
            }
        }

        parraLogV("Sending data...")
        
        
        for (_, module) in Parra.registeredModules {
            await module.triggerSync()
        }

        parraLogV("Data sent")
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
