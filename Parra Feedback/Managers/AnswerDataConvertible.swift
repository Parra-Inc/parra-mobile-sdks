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
    case single(QuestionSingleChoiceCompletedData)
    case multiple(QuestionMultipleChoiceCompletedData)
}

enum QuestionCompletedData: Codable {
    case choice(QuestionChoiceCompletedData)
}

enum CompletedCardData: Codable {
    case question(QuestionCompletedData)
}

struct CompletedCard: Codable {
    let id: String
    let data: CompletedCardData
}
