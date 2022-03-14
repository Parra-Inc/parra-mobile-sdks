//
//  ParraFeedback.swift
//  Feedback
//
//  Created by Mick MacCallum on 3/12/22.
//

import Foundation
import ParraCore

public class ParraFeedback: ParraModule {
    internal static let shared = ParraFeedback()
    internal let dataManager = ParraFeedbackDataManager()
    
    private init() {
        Parra.registerModule(module: self)
    }
    
    public static var name: String = "Feedback"
        
    public class func fetchFeedbackCards(completion: @escaping ([CardItem], ParraError?) -> Void) {
        Task {
            do {
                let cards = try await fetchFeedbackCards()
                
                DispatchQueue.main.async {
                    completion(cards, nil)
                }
            } catch let error {
                DispatchQueue.main.async {
                    completion([], ParraError.dataLoadingError(error.localizedDescription))
                }
            }
        }
    }
    
    public class func fetchFeedbackCards() async throws -> [CardItem] {
        let cards = try await Parra.API.getCards()
        
        // Only keep cards that we don't already have an answer cached for. This isn't something that
        // should ever even happen, but in event that new cards are retreived that include cards we
        // already have an answer for, we'll keep the answered cards hidden and they'll be flushed
        // the next time a sync is triggered.
        var cardsToKeep = [CardItem]()

        for card in cards {
            switch card.data {
            case .question(let question):
                let previouslyCleared = await shared.dataManager.hasClearedCompletedCardWithId(card: card)
                let cardData = await shared.dataManager.completedCardData(forId: question.id)
            
                if !previouslyCleared && cardData == nil {
                    cardsToKeep.append(card)
                }
            }
        }
                
        shared.dataManager.setCards(cards: cardsToKeep)
        
        return cardsToKeep
    }

    public func triggerSync() async {
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
                        await self.dataManager.removeCardsForCompletedCards(completedCards: chunk)
                    } catch let error {
                        parraLogE("Error uploading card data: \(ParraError.networkError(error.localizedDescription))")
                    }
                }
            }
        }
    }

    private func uploadCompletedCards(_ cards: [CompletedCard]) async throws {
        try await Parra.API.bulkAnswerQuestions(cards: cards)
    }
    
    public func hasDataToSync() async -> Bool {
        let answers = await dataManager.currentCompletedCardData()
        
        return !answers.isEmpty
    }
}
