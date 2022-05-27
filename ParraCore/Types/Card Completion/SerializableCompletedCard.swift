//
//  SerializableCompletedCard.swift
//  ParraCore
//
//  Created by Mick MacCallum on 3/13/22.
//

import Foundation

public struct SerializableCompletedCard: Encodable {
    enum CodingKeys: CodingKey {
        case data
        case questionId
    }
    
    public let completedCard: CompletedCard
    
    public init(completedCard: CompletedCard) {
        self.completedCard = completedCard
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        switch completedCard.data {
        case .question(let questionCompletedData):
            try container.encode(completedCard.id, forKey: .questionId)
            
            switch questionCompletedData {
            case .choice(let questionChoiceCompletedData):
                switch questionChoiceCompletedData {
                case .single(let questionSingleChoiceCompletedData):
                    try container.encode(questionSingleChoiceCompletedData, forKey: .data)
                case .multiple(let questionMultipleChoiceCompletedData):
                    try container.encode(questionMultipleChoiceCompletedData, forKey: .data)
                }
            }
        }
    }
}
