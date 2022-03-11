//
//  ParraFeedbackDataManager.swift
//  Parra Feedback
//
//  Created by Michael MacCallum on 1/1/22.
//

import Foundation

// TODO: Restructure
/**
 * 1. Need to create a unified interface around when sessions start and stop.
 *      * Sessions start when app enters the foreground and ends when the app enters the background
 *      * Each session should be written to its own file on disk
 *      * Session data should be able to be streamed to and from disk (can this be done if we want to update the answer to an existing question? Or should we just do this for events)
 *      *
 *
 *      * Sessions should be donated
 * 2.
 */

class ParraFeedbackDataManager {
    private let credentialStorage: CredentialStorage
    private let completedCardDataStorage: CompletedCardDataStorage
    private let cardStorage: CardStorage
    internal private(set) var isLoaded = false
        
    init() {
        let userDefaults = UserDefaults.standard
        let jsonEncoder = JSONEncoder()
        let jsonDecoder = JSONDecoder()
        
        let memoryStorage = MemoryStorage()
        
        let userDefaultsStorage = UserDefaultsStorage(
            userDefaults: userDefaults,
            jsonEncoder: jsonEncoder,
            jsonDecoder: jsonDecoder
        )
        
        let fileSystemStorage = FileSystemStorage(
            baseUrl: ParraFeedbackDataManager.Path.parraFeedbackDirectory,
            jsonEncoder: jsonEncoder,
            jsonDecoder: jsonDecoder
        )
        
        self.credentialStorage = CredentialStorage(storageMedium: userDefaultsStorage)
        self.completedCardDataStorage = CompletedCardDataStorage(storageMedium: fileSystemStorage)
        self.cardStorage = CardStorage(storageMedium: memoryStorage)
    }
    
    // MARK: - User Credentials
    func getCurrentCredential() async -> ParraFeedbackCredential? {
        return await credentialStorage.currentCredential()
    }
    
    func updateCredential(credential: ParraFeedbackCredential?) async {
        await credentialStorage.updateCredential(credential: credential)
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
        for card in currentCards() {
            let isFullfilled = await completedCardDataStorage.completedCardData(forId: card.id) != nil

            if !isFullfilled {
                allCardsAreFullfilled = false
                break
            }
        }
        
        if allCardsAreFullfilled {
            ParraFeedback.triggerSync()
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
    
    func currentCards() -> [CardItem] {
        return cardStorage.currentCards()
    }
    
    func removeCardsForCompletedCards(completedCards: [CompletedCard]) {
        let cardIds = completedCards.map { $0.id }
        
        let currentCards = cardStorage.currentCards()
        let remainingCards = currentCards.filter { !cardIds.contains($0.id) }
        
        setCards(cards: remainingCards)
    }
    
    func hasClearedCompletedCardWithId(card: CardItem) async -> Bool {
        return await completedCardDataStorage.hasClearedCompletedCardWithId(
            cardId: card.id
        )
    }
    
    func setCards(cards: [CardItem]) {
        cardStorage.setCards(cardItems: cards)
        
        DispatchQueue.main.async {
            NotificationCenter.default.post(
                name: ParraFeedback.cardsDidChangeNotification,
                object: nil
            )
        }
    }
    
    func loadData() async throws {
        let _ = await [
            credentialStorage.loadData(),
            completedCardDataStorage.loadData(),
        ]
        
        isLoaded = true
    }
    
    func logEvent() {
        // TODO: should log an event to the current session.
        // TODO: Should be called in addition to updating answers.
    }
}

extension CardItem: Identifiable {
    public var id: String {
        switch data {
        case .question(let question):
            return question.id
        }
    }
}
