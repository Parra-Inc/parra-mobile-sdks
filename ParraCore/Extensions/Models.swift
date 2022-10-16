//
//  Models.swift
//  Parra Core
//
//  Created by Michael MacCallum on 1/6/22.
//

import Foundation

public enum QuestionChoiceDirection {
    case vertical, horizontal
}

public extension QuestionKind {
    var allowsMultipleSelection: Bool {
        switch self {
        case .radio, .star, .image:
            return false
        case .checkbox:
            return true
        }
    }
    
    var allowsDeselection: Bool {
        switch self {
        case .radio, .star, .image:
            return false
        case .checkbox:
            return true
        }
    }

    var direction: QuestionChoiceDirection {
        switch self {
        case .radio, .checkbox:
            return .vertical
        case .star, .image:
            return .horizontal
        }
    }
}

extension ParraCardItem: Identifiable {
    public var id: String {
        switch data {
        case .question(let question):
            return question.id
        }
    }
}
