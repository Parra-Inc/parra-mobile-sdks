//
//  Models.swift
//  Parra
//
//  Created by Michael MacCallum on 1/6/22.
//

import Foundation

extension ParraCardItem {
    func getAllAssets() -> [Asset] {
        switch data {
        case .question(let question):
            switch question.data {
            case .imageQuestionBody(let imageQuestionBody):
                return imageQuestionBody.options.map(\.asset)
            case .longTextQuestionBody, .shortTextQuestionBody,
                 .ratingQuestionBody,
                 .starQuestionBody, .booleanQuestionBody, .choiceQuestionBody,
                 .checkboxQuestionBody:
                return []
            }
        }
    }

    /// Cards that don't have a good mechanism for determining that the user is done making their selection.
    /// This determines which cards show the forward arrow button to manually commit their changes.
    var requiresManualNextSelection: Bool {
        switch data {
        case .question(let question):
            switch question.kind {
            case .checkbox, .textLong:
                return true
            case .image, .boolean, .radio, .rating, .star, .textShort:
                return false
            }
        }
    }
}
