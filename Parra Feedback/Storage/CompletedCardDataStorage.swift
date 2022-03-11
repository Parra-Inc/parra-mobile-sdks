//
//  CardDataStorage.swift
//  Parra Feedback
//
//  Created by Mick MacCallum on 3/6/22.
//

import Foundation

actor CompletedCardDataStorage: ItemStorage {
    let storageMedium: DataStorageMedium
    /// In memory cache of card ids that have been seen recently. This will be reset
    /// when the app is re-launched, but no reset when the cards are changed or cleared.
    /// This is used to make sure that we can hide cards a user has already answered if
    /// they are returned in a response from a card endpoint.
    private var successfullSubmittedCompletedCardIds = Set<String>()

    private var underlyingStorage = [String: CompletedCard]()
    
    init(storageMedium: DataStorageMedium) {
        self.storageMedium = storageMedium
    }
    
    func loadData() async {
        guard let existing: [String: CompletedCard] = try? await storageMedium.read(name: ParraFeedbackDataManager.Key.answersKey) else {
            return
        }
        
        underlyingStorage = existing
    }
    
    func completedCardData(forId id: String) -> CompletedCard? {
        return underlyingStorage[id]
    }
    
    func currentCompletedCardData() -> [String: CompletedCard] {
        return underlyingStorage
    }
    
    func completeCard(completedCard: CompletedCard) async {
        underlyingStorage[completedCard.id] = completedCard
        
        do {
            try await writeAnswers()
        } catch let error {
            let dataError = ParraFeedbackError.dataLoadingError(error)
            parraLogE("Error writing answer data: \(dataError)")
        }
    }
    
    func clearCompletedCardData(completedCards: [CompletedCard] = []) async throws {
        if completedCards.isEmpty {
            for (_, card) in underlyingStorage {
                successfullSubmittedCompletedCardIds.update(with: card.id)
            }
            
            underlyingStorage.removeAll()
        } else {
            for completedCard in completedCards {
                successfullSubmittedCompletedCardIds.update(with: completedCard.id)
                underlyingStorage.removeValue(forKey: completedCard.id)
            }
        }
                
        try await storageMedium.write(
            name: ParraFeedbackDataManager.Key.answersKey,
            value: underlyingStorage
        )
    }
    
    func writeAnswers() async throws {
        try await storageMedium.write(
            name: ParraFeedbackDataManager.Key.answersKey,
            value: underlyingStorage
        )
    }

    func hasClearedCompletedCardWithId(cardId: String) -> Bool {
        return successfullSubmittedCompletedCardIds.contains(cardId)
    }
}
