//
//  ParraReactionOptionGroup+Fixtures.swift
//  Parra
//
//  Created by Mick MacCallum on 12/11/24.
//

import Foundation

extension ParraReactionOptionGroup: ParraFixture {
    public static func validStates() -> [ParraReactionOptionGroup] {
        return [
            ParraReactionOptionGroup(
                id: "emojis",
                name: "Emojis",
                description: "Standard set of emoji reactions",
                options: [
                    ParraReactionOption(
                        id: .uuid,
                        name: "smiley_face",
                        type: .emoji,
                        value: "😀"
                    ),
                    ParraReactionOption(
                        id: .uuid,
                        name: "frown_face",
                        type: .emoji,
                        value: "🙁"
                    ),
                    ParraReactionOption(
                        id: .uuid,
                        name: "thumb_down",
                        type: .emoji,
                        value: "👎"
                    ),
                    ParraReactionOption(
                        id: .uuid,
                        name: "fire",
                        type: .emoji,
                        value: "🔥"
                    ),
                    ParraReactionOption(
                        id: .uuid,
                        name: "heart",
                        type: .emoji,
                        value: "❤️"
                    )
                ]
            )
        ]
    }

    public static func invalidStates() -> [ParraReactionOptionGroup] {
        return []
    }
}
