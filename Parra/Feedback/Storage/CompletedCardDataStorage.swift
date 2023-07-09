//
//  CardDataStorage.swift
//  Parra
//
//  Created by Mick MacCallum on 3/6/22.
//

import Foundation

internal actor CompletedCardDataStorage: ItemStorage {
    internal typealias DataType = CompletedCard
    
    internal let storageModule: ParraStorageModule<CompletedCard>
    
    /// In memory cache of card ids that have been seen recently. This will be reset
    /// when the app is re-launched, but no reset when the cards are changed or cleared.
    /// This is used to make sure that we can hide cards a user has already answered if
    /// they are returned in a response from a card endpoint.
    private var successfullSubmittedCompletedCardIds = Set<String>()
    
    internal init(storageModule: ParraStorageModule<CompletedCard>) {
        self.storageModule = storageModule
    }
    
    internal func completedCardData(forId id: String) async -> CompletedCard? {
        return await storageModule.read(name: id)
    }
    
    internal func currentCompletedCardData() async -> [String: CompletedCard] {
        return await storageModule.currentData()
    }
    
    internal func completeCard(completedCard: CompletedCard) async {
        do {
            try await storageModule.write(
                name: completedCard.bucketItemId,
                value: completedCard
            )
        } catch let error {
            Logger.error("Error writing completed card to cache", error)
        }
    }
    
    internal func clearCompletedCardData(completedCards: [CompletedCard] = []) async throws {
        let underlyingStorage = await storageModule.currentData()
        
        if completedCards.isEmpty {
            for (_, card) in underlyingStorage {
                successfullSubmittedCompletedCardIds.update(
                    with: card.bucketItemId
                )
            }
            
            await storageModule.clear()
        } else {
            for completedCard in completedCards {
                successfullSubmittedCompletedCardIds.update(
                    with: completedCard.bucketItemId
                )

                await storageModule.delete(
                    name: completedCard.bucketItemId
                )
            }
        }
    }
    
    internal func hasClearedCompletedCardWithId(cardId: String) -> Bool {
        return successfullSubmittedCompletedCardIds.contains(cardId)
    }
}
