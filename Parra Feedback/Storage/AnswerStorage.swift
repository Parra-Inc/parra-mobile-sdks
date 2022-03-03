//
//  AnswerStorage.swift
//  Parra Feedback
//
//  Created by Michael MacCallum on 3/2/22.
//

import Foundation

private let kAnswersKey = "com.parrafeedback.answers.data"

actor AnswerStorage: PersistentStorage {
    let storageMedium: DataStorageMedium
    private var underlyingStorage = [String: Answer]()
    
    init(storageMedium: DataStorageMedium) {
        self.storageMedium = storageMedium
    }
    
    func loadData() async {
        guard let existing: [String: Answer] = try? await storageMedium.read(name: kAnswersKey) else {
            return
        }
        
        underlyingStorage = existing
    }
    
    func updateAnswer(answer: Answer) {
        underlyingStorage[answer.questionId] = answer
        
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
