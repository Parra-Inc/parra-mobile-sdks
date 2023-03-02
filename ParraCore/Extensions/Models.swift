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
}
