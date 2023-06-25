//
//  CompletedCard.swift
//  ParraCore
//
//  Created by Mick MacCallum on 3/13/22.
//

import Foundation

// Completed card needs to be able to be converted to and from JSON for storage on disk.
public struct CompletedCard: Codable {
    public let bucketItemId: String
    public let questionId: String
    public let data: QuestionAnswer
    
    public init(
        bucketItemId: String,
        questionId: String,
        data: QuestionAnswer
    ) {
        self.bucketItemId = bucketItemId
        self.questionId = questionId
        self.data = data
    }
}

// A special wrapper around CompletedCard to convert it into JSON suitable to sending the Parra API.
// This is a lossy operation, so must be a separate type from CompletedCard, which is used for local storage.
internal struct CompletedCardUpload: Encodable {
    enum CodingKeys: String, CodingKey {
        case bucketItemId
        case questionId
        case data
    }

    internal let completedCard: CompletedCard

    init(completedCard: CompletedCard) {
        self.completedCard = completedCard
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(completedCard.bucketItemId, forKey: .bucketItemId)
        try container.encode(completedCard.questionId, forKey: .questionId)
        try container.encode(completedCard.data.data, forKey: .data)
    }
}
