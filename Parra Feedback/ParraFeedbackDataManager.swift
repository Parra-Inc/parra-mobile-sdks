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
    
    let queue = DispatchQueue(
        label: "com.parra.feedback.dataQueue",
        qos: .utility,
        // serial by default
        attributes: [],
        autoreleaseFrequency: .workItem
    )
    
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
    }
    
    func currentCards() -> [CardItem] {
        return cardStorage.currentCards()
    }
    
    func updateCards(cards: [CardItem]) {
        cardStorage.updateCards(cardItems: cards)
    }
    
    /// Depending on the value of the replace arguement, either replaces the existing cards with the supplied ones
    /// or attempts to merge the supplied cards with the current cards, attempting to keep order similar.
//    func storeCards(cards: [CardItem], replace: Bool = true) {
//        queue.async {
//            let cardDataList = cards.map { $0.data }
//
//            if replace {
//                self.cardDataMap = self.cardDataMapFromList(
//                    cardDataList: cardDataList
//                )
//            } else {
//
//                for (index, data) in cardDataList.lazy.enumerated() {
//                    if let existing = self.cardDataMap[data.id] {
//                        // If there is already a card with this id, update the card but leave it in the same
//                        // place in the list it existed in previously.
//                        self.cardDataMap[data.id] = (existing.index, data)
//                    } else {
//                        // This is a new card that we weren't tracking. Use the index within the new list
//                        // as the index for the card in the main list. This is a best guess and will just be used
//                        // during sorting later so it doesn't need to be exact.
//                        self.cardDataMap[data.id] = (index, data)
//                    }
//                }
//            }
//
//            self.writeCardData()
//        }
//    }
        
//    func currentData<T: ReadWriteable>() async -> [T] {
//        return await withCheckedContinuation { continuation in
//            queue.async {
//                continuation.resume(returning: [])
//            }
//        }
//    }
    
    func loadData() async throws {
        let _ = await [
            credentialStorage.loadData(),
            answerStorage.loadData()
        ]
        
        isLoaded = true
    }
    
    func logEvent() {
        // TODO: should log an event to the current session.
        // TODO: Should be called in addition to updating answers.
    }
        
//    private func loadCardData() async throws -> FastAccessListMap<CardItemData> {
//        let fileManager = FileManager.default
//        let url = kParraCardDataPath
//
//        guard fileManager.fileExists(atPath: url.path) else {
//            return [:]
//        }
//
//        let data = try Data(contentsOf: url)
//
//        return cardDataMapFromList(
//            cardDataList: try JSONDecoder.parraDecoder.decode([CardItemData].self, from: data)
//        )
//    }
//
//    private func loadAnswers() async throws -> [String: Answer] {
//        let fileManager = FileManager.default
//        let url = kParraAnswerDataPath
//
//        guard fileManager.fileExists(atPath: url.path) else {
//            return [:]
//        }
//
//        let data = try Data(contentsOf: url)
//
//        return answersMapFromList(
//            answers: try JSONDecoder.parraDecoder.decode([Answer].self, from: data)
//        )
//    }
    
    func cardDataMapFromList(cardDataList: [CardItemData]) -> FastAccessListMap<CardItemData> {
        return cardDataList.lazy.enumerated().reduce([:]) { partialResult, obj in
            var result = partialResult

            result[obj.element.id] = (obj.offset, obj.element)

            return result
        }
    }
    
    func cardDataListFromMap(cardDataMap: FastAccessListMap<CardItemData>) -> [CardItemData] {
        return cardDataMap.values.sorted {
            $0.index < $1.index
        }.map {
            $0.element
        }
    }
    
    func answersMapFromList(answers: [Answer]) -> [String: Answer] {
        return answers.reduce([:]) { partialResult, element in
            var result = partialResult

            result[element.id] = element

            return result
        }
    }
    
//    func answersListFromMap(answerDataMap: [String: Answer]) -> [Answer] {
//        return Array(answerDataMap.values)
//    }
    
//    private func writeCardData() {
//
//    }
//
//    private func writeAnswers() {
//
//    }
}

extension CardItemData: Identifiable {
    public var id: String {
        switch self {
        case .question(let question):
            return "question_\(question.id)"
        }
    }
}
