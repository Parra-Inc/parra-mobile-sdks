//
//  Models.swift
//  Parra Core
//
//  Created by Michael MacCallum on 1/6/22.
//

import Foundation

extension ParraCardItem: Identifiable {
    public var id: String {
        switch data {
        case .question(let question):
            return question.id
        }
    }

    public func getAllAssets() -> [Asset] {
        switch self.data {
        case .question(let question):
            switch question.data {
            case .imageQuestionBody(let imageQuestionBody):
                return imageQuestionBody.options.map { $0.asset }
            case .longTextQuestionBody, .shortTextQuestionBody, .ratingQuestionBody,
                    .starQuestionBody, .booleanQuestionBody, .choiceQuestionBody, .checkboxQuestionBody:
                return []
            }
        }
    }
}
