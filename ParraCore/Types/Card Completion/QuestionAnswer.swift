//
//  QuestionAnswer.swift
//  ParraCore
//
//  Created by Mick MacCallum on 2/23/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation

public protocol AnswerOption: Codable {}

public struct SingleOptionAnswer: AnswerOption {
    public let optionId: String

    public init(optionId: String) {
        self.optionId = optionId
    }
}

public struct MultiOptionIndividualOption: Codable {
    public let id: String

    public init(id: String) {
        self.id = id
    }
}

public struct MultiOptionAnswer: AnswerOption {
    public let options: [MultiOptionIndividualOption]

    public init(options: [MultiOptionIndividualOption]) {
        self.options = options
    }
}

public struct TextValueAnswer: AnswerOption {
    public let value: String

    public init(value: String) {
        self.value = value
    }
}

public struct IntValueAnswer: AnswerOption {
    public let value: Int

    public init(value: Int) {
        self.value = value
    }
}

public enum QuestionAnswerKind: Codable {
    case checkbox(MultiOptionAnswer)
    case radio(SingleOptionAnswer)
    case boolean(SingleOptionAnswer)
    case image(SingleOptionAnswer)
    case rating(SingleOptionAnswer)
    case star(IntValueAnswer)
    case textShort(TextValueAnswer)
    case textLong(TextValueAnswer)
}

public struct QuestionAnswer: Codable {
    public let kind: QuestionKind
    public let data: any AnswerOption

    public init(kind: QuestionKind, data: AnswerOption) {
        self.kind = kind
        self.data = data
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.kind = try container.decode(QuestionKind.self, forKey: .kind)
        switch self.kind {
        case .checkbox:
            self.data = try container.decode(MultiOptionAnswer.self, forKey: .data)
        case .radio, .boolean, .image, .rating:
            self.data = try container.decode(SingleOptionAnswer.self, forKey: .data)
        case .star:
            self.data = try container.decode(IntValueAnswer.self, forKey: .data)
        case .textLong, .textShort:
            self.data = try container.decode(TextValueAnswer.self, forKey: .data)
        }
    }

    enum CodingKeys: CodingKey {
        case kind
        case data
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(kind, forKey: .kind)
        try container.encode(data, forKey: .data)
    }
}
