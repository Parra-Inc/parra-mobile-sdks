//
//  GeneratedTypes+Extensions.swift
//  Parra Feedback
//
//  Created by Michael MacCallum on 1/6/22.
//

import Foundation

extension QuestionKind {
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
