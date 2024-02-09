//
//  CompletedCard.swift
//  Parra
//
//  Created by Mick MacCallum on 3/13/22.
//

import Foundation

// Completed card needs to be able to be converted to and from JSON for storage on disk.
struct CompletedCard: Codable {
    // MARK: - Lifecycle

    init(
        bucketItemId: String,
        questionId: String,
        data: QuestionAnswer
    ) {
        self.bucketItemId = bucketItemId
        self.questionId = questionId
        self.data = data
    }

    // MARK: - Internal

    let bucketItemId: String
    let questionId: String
    let data: QuestionAnswer
}

// A special wrapper around CompletedCard to convert it into JSON suitable to sending the Parra API.
// This is a lossy operation, so must be a separate type from CompletedCard, which is used for local storage.
struct CompletedCardUpload: Encodable {
    // MARK: - Lifecycle

    init(completedCard: CompletedCard) {
        self.completedCard = completedCard
    }

    // MARK: - Internal

    enum CodingKeys: String, CodingKey {
        case bucketItemId
        case questionId
        case data
    }

    let completedCard: CompletedCard

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(completedCard.bucketItemId, forKey: .bucketItemId)
        try container.encode(completedCard.questionId, forKey: .questionId)
        try container.encode(completedCard.data.data, forKey: .data)
    }
}
