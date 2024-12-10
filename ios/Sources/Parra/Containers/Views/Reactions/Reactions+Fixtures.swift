//
//  Reactions+Fixtures.swift
//  Parra
//
//  Created by Mick MacCallum on 12/9/24.
//

import Foundation

extension ReactionSummary: ParraFixture {
    static func validStates() -> [ReactionSummary] {
        return []
    }

    static func invalidStates() -> [ReactionSummary] {
        return []
    }
}
