//
//  AnswerStorage.swift
//  Parra Feedback
//
//  Created by Michael MacCallum on 3/2/22.
//

import Foundation

private let kAnswersKey = "com.parrafeedback.answers.data"

actor AnswerStorage: ItemStorage {
    let storageMedium: DataStorageMedium
    private var underlyingStorage = [String: QuestionAnswer]()
    
    init(storageMedium: DataStorageMedium) {
        self.storageMedium = storageMedium
    }
    
    func loadData() async {
        guard let existing: [String: QuestionAnswer] = try? await storageMedium.read(name: kAnswersKey) else {
            return
        }
        
        underlyingStorage = existing
    }
    
    func answerData(forQuestion question: Question) -> QuestionAnswer? {
        return underlyingStorage[question.id]
    }
    
    func currentAnswerData() -> [String: QuestionAnswer] {
        return underlyingStorage
    }
    
    func updateAnswerData(answerData: QuestionAnswerData) async {
        underlyingStorage[answerData.questionId] = answerData.data
        
        Task {
            do {
                try await writeAnswers()
            } catch let error {
                let dataError = ParraFeedbackError.dataLoadingError(error)
                print("\(kParraLogPrefix) Error writing answer data: \(dataError)")
            }
        }
    }
    
    func writeAnswers() async throws {
        try await storageMedium.write(name: kAnswersKey, value: underlyingStorage)
    }
}
