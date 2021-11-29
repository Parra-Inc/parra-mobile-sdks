//
//  ParraFeedback+Types.swift
//  Parra Feedback
//
//  Created by Michael MacCallum on 11/28/21.
//

import Foundation

public enum ParraFeedbackError: Error {
    case missingAuthentication
    case authenticationFailed(Error)
}

public struct ParraFeedbackUserCredential {
    public let name: String
    public let token: String
    
    public init(name: String, token: String) {
        self.name = name
        self.token = token
    }
}

//{
//        "id": "1",
//      "type": "choice|text|rating",
//        "title": "",
//        "subtitle": "",
//      "data": {
//            "type": "radio|checkbox|drop_down",
//          "options": [
//                {
//                    "title": "",
//                    "value": "",
//                    "is_other": "true|false"
//                }
//            ],
//      }
//}

public struct ParraFeedbackChoiceOption: CustomStringConvertible {
    public let id: String
    public let title: String
    public let value: String
    
    public var description: String {
        return "ParraFeedbackChoiceOption:{id: \(id), title: \(title), value:\(value)}"
    }
}

extension ParraFeedbackChoiceOption: Equatable {
    public static func == (lhs: ParraFeedbackChoiceOption, rhs: ParraFeedbackChoiceOption) -> Bool {
        return lhs.id == rhs.id && lhs.title == rhs.title && lhs.value == rhs.value
    }
}

public enum ParraFeedbackChoiceOptionType: String {
    case radio = "radio"
    case checkbox = "checkbox"
    case dropDown = "drop_down"
}

public struct ParraFeedbackQuestionTypeChoice {
    public let optionType: ParraFeedbackChoiceOptionType
    public let options: [ParraFeedbackChoiceOption]
}

extension ParraFeedbackQuestionTypeChoice: Equatable {
    public static func == (lhs: ParraFeedbackQuestionTypeChoice, rhs: ParraFeedbackQuestionTypeChoice) -> Bool {
        return lhs.optionType == rhs.optionType
            && lhs.options == rhs.options
    }
}

public struct ParraFeedbackQuestionTypeForm {
    public let multiLine: Bool
    public let placeholderText: String?
}

extension ParraFeedbackQuestionTypeForm: Equatable {
    public static func == (lhs: ParraFeedbackQuestionTypeForm, rhs: ParraFeedbackQuestionTypeForm) -> Bool {
        return lhs.multiLine == rhs.multiLine
            && lhs.placeholderText == rhs.placeholderText
    }
}

public enum ParraFeedbackQuestionType {
    case choice(ParraFeedbackQuestionTypeChoice)
    case form(ParraFeedbackQuestionTypeForm)
}

extension ParraFeedbackQuestionType: Equatable {
    public static func == (lhs: ParraFeedbackQuestionType, rhs: ParraFeedbackQuestionType) -> Bool {
        switch (lhs, rhs) {
        case (.choice(let c1), .choice(let c2)):
            return c1 == c2
        case (.form(let f1), .form(let f2)):
            return f1 == f2
        default:
            return false
        }
    }
}

// Questions have different options like choice for multiple choice or free response.
public struct ParraFeedbackQuestion {
    public let id: String
    public let type: ParraFeedbackQuestionType
    public let title: String
    public let subtitle: String?
}

extension ParraFeedbackQuestion: Equatable {
    public static func == (lhs: ParraFeedbackQuestion, rhs: ParraFeedbackQuestion) -> Bool {
        return lhs.id == rhs.id
        && lhs.type == rhs.type
        && lhs.title == rhs.title
        && lhs.subtitle == rhs.subtitle
    }
}

public enum ParraFeedbackCardItem {
    case question(ParraFeedbackQuestion)
}

extension ParraFeedbackCardItem: Equatable {
    public static func == (lhs: ParraFeedbackCardItem, rhs: ParraFeedbackCardItem) -> Bool {
        switch (lhs, rhs) {
        case (.question(let q1), .question(let q2)):
            return q1 == q2
        }
    }
}

public struct ParraFeedbackCardsResponse {
    public let version: String
    public let cards: [ParraFeedbackCardItem]
}
