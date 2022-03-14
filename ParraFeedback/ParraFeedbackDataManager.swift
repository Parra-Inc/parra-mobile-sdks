//
//  ParraFeedbackDataManager.swift
//  Parra Feedback
//
//  Created by Michael MacCallum on 1/1/22.
//

import Foundation
import ParraCore

class ParraFeedbackDataManager {
    private let completedCardDataStorage: CompletedCardDataStorage
    private let cardStorage: CardStorage
        
    init() {
        let completedCardDataFolder = ParraFeedback.persistentStorageFolder()
        let completedCardDataFileName = ParraFeedbackDataManager.Key.completedCardsKey
        
        let completedCardDataStorageModule = ParraStorageModule<CompletedCard>(
            dataStorageMedium: .fileSystem(
                folder: completedCardDataFolder,
                fileName: completedCardDataFileName
            )
        )
        
        self.completedCardDataStorage = CompletedCardDataStorage(
            storageModule: completedCardDataStorageModule
        )
        
        let cardStorageModule = ParraStorageModule<[CardItem]>(
            dataStorageMedium: .memory
        )
        
        self.cardStorage = CardStorage(
            storageModule: cardStorageModule
        )
    }
    
    
    func completedCardData(forId id: String) async -> CompletedCard? {
        return await completedCardDataStorage.completedCardData(
            forId: id
        )
    }
    
    func completeCard(_ completedCard: CompletedCard) async {
        await completedCardDataStorage.completeCard(
            completedCard: completedCard
        )
        
        // Check if all the cards have been fullfilled. If they have, trigger a sync event.
        var allCardsAreFullfilled = true
        for card in await currentCards() {
            let isFullfilled = await completedCardDataStorage.completedCardData(forId: card.id) != nil

            if !isFullfilled {
                allCardsAreFullfilled = false
                break
            }
        }
        
        if allCardsAreFullfilled {
            Parra.triggerSync()
        }
    }

    func currentCompletedCardData() async -> [String: CompletedCard] {
        return await completedCardDataStorage.currentCompletedCardData()
    }
    
    func clearCompletedCardData(completedCards: [CompletedCard] = []) async throws {
        try await completedCardDataStorage.clearCompletedCardData(
            completedCards: completedCards
        )
    }
    
    func currentCards() async -> [CardItem] {
        return await cardStorage.currentCards()
    }
    
    func removeCardsForCompletedCards(completedCards: [CompletedCard]) async {
        let cardIds = completedCards.map { $0.id }
        
        let currentCards = await cardStorage.currentCards()
        let remainingCards = currentCards.filter { !cardIds.contains($0.id) }
        
        setCards(cards: remainingCards)
    }
    
    func hasClearedCompletedCardWithId(card: CardItem) async -> Bool {
        return await completedCardDataStorage.hasClearedCompletedCardWithId(
            cardId: card.id
        )
    }
    
    func setCards(cards: [CardItem]) {
        Task {
            await cardStorage.setCards(cardItems: cards)
            
            await MainActor.run {
                DispatchQueue.main.async {
                    NotificationCenter.default.post(
                        name: ParraFeedback.cardsDidChangeNotification,
                        object: nil
                    )
                }
            }
        }
    }
    
    func logEvent() {
        // TODO: should log an event to the current session.
        // TODO: Should be called in addition to updating answers.
    }
}
