//
//  Reaction+Fixtures.swift
//  Parra
//
//  Created by Mick MacCallum on 3/5/25.
//

import Foundation

extension Reaction: ParraFixture {
    static func validStates() -> [Reaction] {
        return [
            Reaction(
                id: .uuid,
                optionId: .uuid,
                userId: .uuid,
                user: ParraUserNameStub(
                    id: .uuid,
                    name: "Mick"
                )
            )
        ]
    }
}
