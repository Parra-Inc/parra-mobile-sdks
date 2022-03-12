//
//  AnswerDataConvertible.swift
//  Parra Feedback
//
//  Created by Michael MacCallum on 3/4/22.
//

import Foundation

struct QuestionSingleChoiceCompletedData: Codable {
    let optionId: String
}

struct QuestionMultipleChoiceCompletedData: Codable {
    let optionIds: [String]
}

enum QuestionChoiceCompletedData: Codable {
    enum CodingKeys: CodingKey {
        case single, multiple
    }

    case single(QuestionSingleChoiceCompletedData)
    case multiple(QuestionMultipleChoiceCompletedData)
    
    init(from decoder: Decoder) throws {
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
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        switch self {
        case .single(let questionSingleChoiceCompletedData):
            try container.encode(questionSingleChoiceCompletedData, forKey: .single)
        case .multiple(let questionMultipleChoiceCompletedData):
            try container.encode(questionMultipleChoiceCompletedData, forKey: .multiple)
        }
    }
}

enum QuestionCompletedData: Codable {
    enum CodingKeys: CodingKey {
        case choice
    }

    case choice(QuestionChoiceCompletedData)
    
    init(from decoder: Decoder) throws {
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

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        switch self {
        case .choice(let questionChoiceCompletedData):
            try container.encode(questionChoiceCompletedData, forKey: .choice)
        }
    }
}

enum CompletedCardData: Codable {
    enum CodingKeys: CodingKey {
        case question
    }

    case question(QuestionCompletedData)
    
    init(from decoder: Decoder) throws {
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
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
     
        switch self {
        case .question(let questionCompletedData):
            try container.encode(questionCompletedData, forKey: .question)
        }
    }
}

struct CompletedCard: Codable {
    let id: String
    let data: CompletedCardData
    
    init(id: String, data: CompletedCardData) {
        self.id = id
        self.data = data
    }
    
    func serializedForRequestBody() -> SerializableCompletedCard {
        return SerializableCompletedCard(completedCard: self)
    }
}

struct SerializableCompletedCard: Encodable {
    enum CodingKeys: CodingKey {
        case data
        case questionId
    }

    let completedCard: CompletedCard
    
    init(completedCard: CompletedCard) {
        self.completedCard = completedCard
    }
    
    func encode(to encoder: Encoder) throws {
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
