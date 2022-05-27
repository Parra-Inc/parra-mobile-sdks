//
//  QuestionCompletedData.swift
//  ParraCore
//
//  Created by Mick MacCallum on 3/13/22.
//

import Foundation

public enum QuestionCompletedData: Codable {
    enum CodingKeys: CodingKey {
        case choice
    }
    
    case choice(QuestionChoiceCompletedData)
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let key = container.allKeys.first
        
        switch key {
        case .choice:
            self = .choice(
                try container.decode(QuestionChoiceCompletedData.self, forKey: .choice)
            )
        default:
            throw DecodingError.dataCorrupted(
                DecodingError.Context(
                    codingPath: container.codingPath,
                    debugDescription: "Unknown Question type"
                )
            )
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        switch self {
        case .choice(let questionChoiceCompletedData):
            try container.encode(questionChoiceCompletedData, forKey: .choice)
        }
    }
}
