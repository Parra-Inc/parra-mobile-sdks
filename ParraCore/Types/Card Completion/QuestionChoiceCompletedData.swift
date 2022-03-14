//
//  QuestionChoiceCompletedData.swift
//  ParraCore
//
//  Created by Mick MacCallum on 3/13/22.
//

import Foundation

public enum QuestionChoiceCompletedData: Codable {
    enum CodingKeys: CodingKey {
        case single, multiple
    }

    case single(QuestionSingleChoiceCompletedData)
    case multiple(QuestionMultipleChoiceCompletedData)
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let key = container.allKeys.first

        switch key {
        case .single:
            self = .single(
                try container.decode(QuestionSingleChoiceCompletedData.self, forKey: .single)
            )
        case .multiple:
            self = .multiple(
                try container.decode(QuestionMultipleChoiceCompletedData.self, forKey: .multiple)
            )
        default:
            throw DecodingError.dataCorrupted(
                DecodingError.Context(
                    codingPath: container.codingPath,
                    debugDescription: "Unknown QuestionChoice type"
                )
            )
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        switch self {
        case .single(let questionSingleChoiceCompletedData):
            try container.encode(questionSingleChoiceCompletedData, forKey: .single)
        case .multiple(let questionMultipleChoiceCompletedData):
            try container.encode(questionMultipleChoiceCompletedData, forKey: .multiple)
        }
    }
}
