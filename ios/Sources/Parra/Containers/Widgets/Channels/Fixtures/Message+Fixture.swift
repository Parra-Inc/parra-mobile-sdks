//
//  Message+Fixture.swift
//  Parra
//
//  Created by Mick MacCallum on 2/13/25.
//

import SwiftUI

extension Message: ParraFixture {
    static var redactedMessage: Message {
        return Message(
            id: .uuid,
            createdAt: .now.daysAgo(1),
            updatedAt: .now.daysAgo(1),
            deletedAt: nil,
            tenantId: .uuid,
            channelId: .uuid,
            memberId: .uuid,
            user: .validStates()[0],
            content: "Some text that you should never see. If you do, report it please :)",
            attachments: []
        )
    }

    public static func validStates() -> [Message] {
        let sampleComments = [
            "Nice work!",
            "Can you explain this part?",
            "I think we should consider using a different approach here.",
            "This looks good to me, but we might want to add some error handling for edge cases.",
            "The performance could be improved by caching these results instead of recalculating them every time the function is called.",
            "I've been testing this extensively and found a few edge cases we should handle: 1) When the input is empty 2) When there are duplicate keys 3) When the data contains special characters. Let me know if you want me to provide specific test cases.",
            "While this implementation works, it might be worth considering using the new API that was released in the latest version. It handles most of these edge cases automatically and has better performance characteristics for large datasets.",
            "Have you considered the memory implications of storing all these objects in an array? For large datasets, we might want to implement pagination or virtual scrolling to prevent potential performance issues. I can help set this up if you're interested in exploring that approach."
        ]

        return sampleComments.enumerated().map { index, element in
            Message(
                id: .uuid,
                createdAt: .now.daysAgo(1),
                updatedAt: .now.daysAgo(1),
                deletedAt: nil,
                tenantId: .uuid,
                channelId: .uuid,
                memberId: .uuid,
                user: .validStates()[index % 2],
                content: element,
                attachments: []
            )
        }
    }
}
