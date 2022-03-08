//
//  CardDataStorage.swift
//  Parra Feedback
//
//  Created by Mick MacCallum on 3/6/22.
//

import Foundation

actor CompletedCardDataStorage: ItemStorage {
    let storageMedium: DataStorageMedium
    
    private var underlyingStorage = [String: CompletedCardData]()
    
    init(storageMedium: DataStorageMedium) {
        self.storageMedium = storageMedium
    }
    
    func loadData() async {
        guard let existing: [String: CompletedCardData] = try? await storageMedium.read(name: ParraFeedbackDataManager.Key.answersKey) else {
            return
        }
        
        underlyingStorage = existing
    }
    
    func completedCardData(forId id: String) -> CompletedCardData? {
        return underlyingStorage[id]
    }
    
    func currentCompletedCardData() -> [String: CompletedCardData] {
        return underlyingStorage
    }
    
    func completeCard(completedCard: CompletedCard) async {
        underlyingStorage[completedCard.id] = completedCard.data
        
        do {
            try await writeAnswers()
        } catch let error {
            let dataError = ParraFeedbackError.dataLoadingError(error)
            parraLogE("Error writing answer data: \(dataError)")
        }
    }
    
    func clearCompletedCardData() async throws {
        underlyingStorage.removeAll()
        
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

}
