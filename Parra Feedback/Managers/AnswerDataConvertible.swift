//
//  AnswerDataConvertible.swift
//  Parra Feedback
//
//  Created by Michael MacCallum on 3/4/22.
//

import Foundation
import AnyCodable

typealias QuestionAnswer = AnyCodable

struct QuestionAnswerData {
    let questionId: String
    let data: QuestionAnswer
}

protocol AnswerDataConvertible {
    func getAnswerData() -> QuestionAnswer
}

extension ChoiceQuestionOption: AnswerDataConvertible {
    func getAnswerData() -> QuestionAnswer {
        return [
            "option_id": id
        ]
    }
}

extension Array: AnswerDataConvertible where Element == ChoiceQuestionOption {
    func getAnswerData() -> QuestionAnswer {
        return [
            "option_ids": map { $0.id }
        ]
    }
}


