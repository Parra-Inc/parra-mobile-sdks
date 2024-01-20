//
//  QuestionAnswer.swift
//  Parra
//
//  Created by Mick MacCallum on 2/23/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation

internal protocol AnswerOption: Codable {}

internal struct SingleOptionAnswer: AnswerOption {
    internal let optionId: String

    internal init(optionId: String) {
        self.optionId = optionId
    }
}

internal struct MultiOptionIndividualOption: Codable {
    internal let id: String

    internal init(id: String) {
        self.id = id
    }
}

internal struct MultiOptionAnswer: AnswerOption {
    internal let options: [MultiOptionIndividualOption]

    internal init(options: [MultiOptionIndividualOption]) {
        self.options = options
    }
}

internal struct TextValueAnswer: AnswerOption {
    internal let value: String

    internal init(value: String) {
        self.value = value
    }
}

internal struct IntValueAnswer: AnswerOption {
    internal let value: Int

    internal init(value: Int) {
        self.value = value
    }
}

internal enum QuestionAnswerKind: Codable {
    case checkbox(MultiOptionAnswer)
    case radio(SingleOptionAnswer)
    case boolean(SingleOptionAnswer)
    case image(SingleOptionAnswer)
    case rating(SingleOptionAnswer)
    case star(IntValueAnswer)
    case textShort(TextValueAnswer)
    case textLong(TextValueAnswer)
}

internal struct QuestionAnswer: Codable {
    internal let kind: QuestionKind
    internal let data: any AnswerOption

    internal init(kind: QuestionKind, data: AnswerOption) {
        self.kind = kind
        self.data = data
    }

    internal init(from decoder: Decoder) throws {
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

    internal func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(kind, forKey: .kind)
        try container.encode(data, forKey: .data)
    }
}
