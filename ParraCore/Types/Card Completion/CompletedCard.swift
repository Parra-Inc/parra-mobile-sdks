//
//  CompletedCard.swift
//  ParraCore
//
//  Created by Mick MacCallum on 3/13/22.
//

import Foundation

public struct CompletedCard: Codable {
    public let id: String
    public let data: CompletedCardData
    
    public init(id: String, data: CompletedCardData) {
        self.id = id
        self.data = data
    }
    
    public func serializedForRequestBody() -> SerializableCompletedCard {
        return SerializableCompletedCard(completedCard: self)
    }
}
