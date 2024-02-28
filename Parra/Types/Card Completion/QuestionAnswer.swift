//
//  QuestionAnswer.swift
//  Parra
//
//  Created by Mick MacCallum on 2/23/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation

protocol AnswerOption: Codable, Equatable {}

struct SingleOptionAnswer: AnswerOption {
    // MARK: - Lifecycle

    init(optionId: String) {
        self.optionId = optionId
    }

    // MARK: - Internal

    let optionId: String
}

struct MultiOptionIndividualOption: Codable, Equatable {
    // MARK: - Lifecycle

    init(id: String) {
        self.id = id
    }

    // MARK: - Internal

    let id: String
}

struct MultiOptionAnswer: AnswerOption {
    // MARK: - Lifecycle

    init(options: [MultiOptionIndividualOption]) {
        self.options = options
    }

    // MARK: - Internal

    let options: [MultiOptionIndividualOption]
}

struct TextValueAnswer: AnswerOption {
    // MARK: - Lifecycle

    init(value: String) {
        self.value = value
    }

    // MARK: - Internal

    let value: String
}

struct IntValueAnswer: AnswerOption {
    // MARK: - Lifecycle

    init(value: Int) {
        self.value = value
    }

    // MARK: - Internal

    let value: Int
}

enum QuestionAnswerKind: Codable, Equatable {
    case checkbox(MultiOptionAnswer)
    case radio(SingleOptionAnswer)
    case boolean(SingleOptionAnswer)
    case image(SingleOptionAnswer)
    case rating(SingleOptionAnswer)
    case star(IntValueAnswer)
    case textShort(TextValueAnswer)
    case textLong(TextValueAnswer)
}

struct QuestionAnswer: Codable, Equatable {
    // MARK: - Lifecycle

    init(kind: QuestionKind, data: any AnswerOption) {
        self.kind = kind
        self.data = data
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.kind = try container.decode(QuestionKind.self, forKey: .kind)
        switch kind {
        case .checkbox:
            self.data = try container.decode(
                MultiOptionAnswer.self,
                forKey: .data
            )
        case .radio, .boolean, .image, .rating:
            self.data = try container.decode(
                SingleOptionAnswer.self,
                forKey: .data
            )
        case .star:
            self.data = try container.decode(IntValueAnswer.self, forKey: .data)
        case .textLong, .textShort:
            self.data = try container.decode(
                TextValueAnswer.self,
                forKey: .data
            )
        }
    }

    // MARK: - Internal

    enum CodingKeys: CodingKey {
        case kind
        case data
    }

    let kind: QuestionKind
    let data: any AnswerOption

    static func == (lhs: QuestionAnswer, rhs: QuestionAnswer) -> Bool {
        if lhs.kind != rhs.kind {
            return false
        }

        // Kind is the same at this point, so compare by data
        switch (lhs.data, rhs.data) {
        case (
            let lAnswer as SingleOptionAnswer,
            let rAnswer as SingleOptionAnswer
        ):
            return lAnswer == rAnswer
        case (
            let lAnswer as MultiOptionAnswer,
            let rAnswer as MultiOptionAnswer
        ):
            return lAnswer == rAnswer
        case (let lAnswer as IntValueAnswer, let rAnswer as IntValueAnswer):
            return lAnswer == rAnswer
        case (let lAnswer as TextValueAnswer, let rAnswer as TextValueAnswer):
            return lAnswer == rAnswer
        default:
            return false
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(kind, forKey: .kind)
        try container.encode(data, forKey: .data)
    }
}
