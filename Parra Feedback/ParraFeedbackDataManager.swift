//
//  ParraFeedbackDataManager.swift
//  Parra Feedback
//
//  Created by Michael MacCallum on 1/1/22.
//

import Foundation

// TODO: Different storage requirement for each type
// TODO: Q Id --> answer
// TODO: Ditch the back button for v1

typealias ReadWriteable = Identifiable & Codable
typealias FastAccessListMap<T> = [String: (index: Int, element: T)]

let kTempDirectory = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
let kParraCardDataPath =  kTempDirectory.appendingPathComponent("Parra/Feedback/cards.data")
let kParraAnswerDataPath =  kTempDirectory.appendingPathComponent("Parra/Feedback/answers.data")

class ParraFeedbackDataManager {
    private var cardDataMap = FastAccessListMap<CardItemData>()
    private var answers = [String: Answer]()
    
    private let jsonDecoder = JSONDecoder()
    
    let queue = DispatchQueue(
        label: "com.parra.feedback.dataQueue",
        qos: .utility,
        // serial by default
        attributes: [],
        autoreleaseFrequency: .workItem
    )
    
    init() {}
    
    // TODO: Should this be updateAnswerToQuestion and key off the question id?
    func updateAnswer(answer: Answer) {
        answers[answer.id] = answer
        writeAnswers()
    }
    
    /// Depending on the value of the replace arguement, either replaces the existing cards with the supplied ones
    /// or attempts to merge the supplied cards with the current cards, attempting to keep order similar.
    func storeCards(cards: [CardItem], replace: Bool = true) {
        queue.async {
            let cardDataList = cards.map { $0.data }
            
            if replace {
                self.cardDataMap = self.cardDataMapFromList(
                    cardDataList: cardDataList
                )
            } else {

                for (index, data) in cardDataList.lazy.enumerated() {
                    if let existing = self.cardDataMap[data.id] {
                        // If there is already a card with this id, update the card but leave it in the same
                        // place in the list it existed in previously.
                        self.cardDataMap[data.id] = (existing.index, data)
                    } else {
                        // This is a new card that we weren't tracking. Use the index within the new list
                        // as the index for the card in the main list. This is a best guess and will just be used
                        // during sorting later so it doesn't need to be exact.
                        self.cardDataMap[data.id] = (index, data)
                    }
                }
            }
            
            self.writeCardData()
        }
    }
        
    func currentData<T: ReadWriteable>() async -> [T] {
        return await withCheckedContinuation { continuation in
            queue.async {
                continuation.resume(returning: [])
            }
        }
    }
    
    func loadData() async throws {
        cardDataMap = try await loadCardData()
        answers = try await loadAnswers()
    }
    
    private func loadCardData() async throws -> FastAccessListMap<CardItemData> {
        let fileManager = FileManager.default
        let url = kParraCardDataPath
        
        guard fileManager.fileExists(atPath: url.path) else {
            return [:]
        }
        
        let data = try Data(contentsOf: url)
                
        return cardDataMapFromList(
            cardDataList: try jsonDecoder.decode([CardItemData].self, from: data)
        )
    }

    private func loadAnswers() async throws -> [String: Answer] {
        let fileManager = FileManager.default
        let url = kParraAnswerDataPath

        guard fileManager.fileExists(atPath: url.path) else {
            return [:]
        }
        
        let data = try Data(contentsOf: url)
        
        return answersDataFromAnswersList(
            answers: try jsonDecoder.decode([Answer].self, from: data)
        )
    }
    
    private func cardDataMapFromList(cardDataList: [CardItemData]) -> FastAccessListMap<CardItemData> {
        return cardDataList.lazy.enumerated().reduce([:]) { partialResult, obj in
            var result = partialResult

            result[obj.element.id] = (obj.offset, obj.element)

            return result
        }
    }
    
    private func questionsListFromQuestionData(questionData: FastAccessListMap<Question>) -> [Question] {
        return questionData.values.sorted {
            $0.index > $1.index
        }.map {
            $0.element
        }
    }
    
    private func answersDataFromAnswersList(answers: [Answer]) -> [String: Answer] {
        return answers.reduce([:]) { partialResult, element in
            var result = partialResult

            result[element.id] = element

            return result
        }
    }
    
    private func answersListFromAnswerData(answerData: [String: Answer]) -> [Answer] {
        return Array(answerData.values)
    }
    
    private func writeCardData() {
        
    }
    
    private func writeAnswers() {
        
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
