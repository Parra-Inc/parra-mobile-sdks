//
//  ParraReactionSummary+Fixtures.swift
//  Parra
//
//  Created by Mick MacCallum on 12/11/24.
//

import Foundation

extension ParraReactionSummary: ParraFixture {
    public static func validStates() -> [ParraReactionSummary] {
        return [
            ParraReactionSummary(
                id: .uuid,
                firstReactionAt: .now,
                name: "smiley_face",
                type: .emoji,
                value: "😀",
                count: 2,
                reactionId: .uuid
            ),
            ParraReactionSummary(
                id: .uuid,
                firstReactionAt: .now,
                name: "thumbs_down",
                type: .emoji,
                value: "👎",
                count: 29,
                reactionId: nil
            )
        ]
    }

    public static func invalidStates() -> [ParraReactionSummary] {
        return []
    }
}
