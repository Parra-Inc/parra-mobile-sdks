//
//  Models.swift
//  Parra Core
//
//  Created by Michael MacCallum on 1/6/22.
//

import Foundation

public extension QuestionKind {
    var allowsMultipleSelection: Bool {
        switch self {
        case .radio, .star:
            return false
        case .checkbox:
            return true
        }
    }

    var allowsDeselection: Bool {
        switch self {
        case .radio, .star:
            return false
        case .checkbox:
            return true
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
