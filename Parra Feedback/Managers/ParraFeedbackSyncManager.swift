//
//  ParraFeedbackSyncManager.swift
//  Parra Feedback
//
//  Created by Michael MacCallum on 3/5/22.
//

import Foundation
import UIKit

actor ParraFeedbackSyncManager {
    private let dataManager: ParraFeedbackDataManager
    private let networkManager: ParraFeedbackNetworkManager
    
    /// Whether or not a sync operation is in progress.
    private var isSyncing = false
    
    /// Whether or not new attempts to sync occured while a sync was in progress. Many sync events could be received while a sync
    /// is in progress so we just track whether any happened. If any happen then we will perform a subsequent sync when the original
    /// is completed.
    private var hasEnqueuedSyncJobs = false
    
    init(dataManager: ParraFeedbackDataManager, networkManager: ParraFeedbackNetworkManager) {
        self.dataManager = dataManager
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
        do {
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
            try await sendData()
            parraLogV("Data sent")
        } catch let error {
            parraLogE("Error syncing data: \(ParraFeedbackError.networkError(error))")
        }
        
    }
    
    private func sendData() async throws {
        await sendCardData()
    }
    
    private func sendCardData() async {
        let completedCardData = await dataManager.currentCompletedCardData()
        let completedCards = Array(completedCardData.values)
        
        let completedChunks = completedCards.chunked(into: ParraFeedback.Constant.maxBulkAnswers)

        await withTaskGroup(of: Void.self) { group in
            for chunk in completedChunks {
                group.addTask {
                    do {
                        try await self.uploadCompletedCards(chunk)
                        try await self.dataManager.clearCompletedCardData(completedCards: chunk)
                        self.dataManager.removeCardsForCompletedCards(completedCards: chunk)
                    } catch let error {
                        parraLogE("Error uploading card data: \(ParraFeedbackError.networkError(error))")
                    }
                }
            }
        }
    }
    
    private func uploadCompletedCards(_ cards: [CompletedCard]) async throws {        
        if cards.isEmpty {
            return
        }
        
        let serializableCards = cards.map { $0.serializedForRequestBody() }

        let route = "bulk/questions/answer"

        let _: EmptyResponseObject = try await networkManager.performAuthenticatedRequest(
            route: route,
            method: .put,
            cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
            body: serializableCards
        )
    }
    
    private func hasDataToSync() async -> Bool {
        let answers = await dataManager.currentCompletedCardData()
        
        return !answers.isEmpty
    }
}
