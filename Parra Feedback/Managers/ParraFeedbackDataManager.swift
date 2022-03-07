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

typealias ReadWriteable = Identifiable & Codable
typealias FastAccessListMap<T> = [String: (index: Int, element: T)]

class ParraFeedbackDataManager {
    private let credentialStorage: CredentialStorage
    private let answerStorage: AnswerStorage
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
        self.answerStorage = AnswerStorage(storageMedium: fileSystemStorage)
        self.cardStorage = CardStorage(storageMedium: memoryStorage)
    }
    
    // MARK: - User Credentials
    func getCurrentCredential() async -> ParraFeedbackCredential? {
        return await credentialStorage.currentCredential()
    }
    
    func updateCredential(credential: ParraFeedbackCredential?) async {
        await credentialStorage.updateCredential(credential: credential)
    }
        
    func answerData(forQuestion question: Question) async -> QuestionAnswer? {
        return await answerStorage.answerData(forQuestion: question)
    }

    func currentAnswerData() async -> [String: QuestionAnswer] {
        return await answerStorage.currentAnswerData()
    }
    
    func updateAnswerData(answerData: QuestionAnswerData) async {
        await answerStorage.updateAnswerData(answerData: answerData)
        
        // Check if all the cards have been fullfilled. If they have, trigger a sync event.
        var allCardsAreFullfilled = true
        for card in currentCards() {
            let isFullfilled: Bool
            switch card.data {
            case .question(let question):
                isFullfilled = await answerStorage.answerData(forQuestion: question) != nil
            }
            
            if !isFullfilled {
                allCardsAreFullfilled = false
                break
            }
        }
        
        if allCardsAreFullfilled {
            ParraFeedback.triggerSync()
        }
    }
    
    func currentCards() -> [CardItem] {
        return cardStorage.currentCards()
    }
    
    func updateCards(cards: [CardItem]) {
        cardStorage.updateCards(cardItems: cards)
        
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: ParraFeedback.cardsDidChangeNotification, object: nil)
        }
    }
    
    func loadData() async throws {
        let _ = await [
            credentialStorage.loadData(),
            answerStorage.loadData()
        ]
        
        isLoaded = true
    }
    
    // Remove data after a sync
    func clearData() async throws {
        updateCards(cards: [])
        
        try await answerStorage.clearAnswers()
        // TODO: Need to make sure the cards that coorespond to the provided answers are removed to.
        // TODO: Need to broadcast an event when the cards change to make sure that the UI updates.
    }
    
    func logEvent() {
        // TODO: should log an event to the current session.
        // TODO: Should be called in addition to updating answers.
    }
}

extension CardItemData: Identifiable {
    public var id: String {
        switch self {
        case .question(let question):
            return "question_\(question.id)"
        }
    }
}
