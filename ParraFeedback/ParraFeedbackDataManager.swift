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
                fileName: completedCardDataFileName,
                storeItemsSeparately: false
            )
        )
        
        self.completedCardDataStorage = CompletedCardDataStorage(
            storageModule: completedCardDataStorageModule
        )
        
        let cardStorageModule = ParraStorageModule<[ParraCardItem]>(
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
        
        var completedCards = [CompletedCard]()
        
        // Check if all the cards have been fullfilled. If they have, trigger a sync event.
        var allCardsAreFullfilled = true
        for card in await currentCards() {
            let completedCard = await completedCardDataStorage.completedCardData(
                forId: card.id
            )
            
            guard let completedCard = completedCard else {
                allCardsAreFullfilled = false
                break
            }

            completedCards.append(completedCard)
        }
        
        if allCardsAreFullfilled {
            // The cards will still be cleaned up later after syncing answers just as a precaution,
            // but we remove them in advance of the sync to trigger a transition to the empty state
            // without having to wait for the sync requests.
            // TODO: Can the cards be restored if the sync fails?
            await removeCardsForCompletedCards(
                completedCards: completedCards
            )

            await Parra.triggerSync()
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
    
    func currentCards() async -> [ParraCardItem] {
        return await cardStorage.currentCards()
    }
    
    func removeCardsForCompletedCards(completedCards: [CompletedCard]) async {
        let cardIds = completedCards.map { $0.questionId }
        
        let currentCards = await cardStorage.currentCards()
        let remainingCards = currentCards.filter { !cardIds.contains($0.id) }
        
        setCards(cards: remainingCards)
    }
    
    func hasClearedCompletedCardWithId(card: ParraCardItem) async -> Bool {
        return await completedCardDataStorage.hasClearedCompletedCardWithId(
            cardId: card.id
        )
    }
    
    func setCards(cards: [ParraCardItem]) {
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
}
