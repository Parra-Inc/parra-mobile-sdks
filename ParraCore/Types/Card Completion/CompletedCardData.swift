//
//  CompletedCardData.swift
//  ParraCore
//
//  Created by Mick MacCallum on 3/13/22.
//

import Foundation

public enum CompletedCardData: Codable {
    enum CodingKeys: CodingKey {
        case question
    }

    case question(QuestionCompletedData)
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let key = container.allKeys.first

        switch key {
        case .question:
            self = .question(
                try container.decode(QuestionCompletedData.self, forKey: .question)
            )
        default:
            throw DecodingError.dataCorrupted(
                DecodingError.Context(
                    codingPath: container.codingPath,
                    debugDescription: "Unknown card type"
                )
            )
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
     
        switch self {
        case .question(let questionCompletedData):
            try container.encode(questionCompletedData, forKey: .question)
        }
    }
}
