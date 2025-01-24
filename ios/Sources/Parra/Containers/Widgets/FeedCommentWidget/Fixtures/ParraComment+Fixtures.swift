//
//  ParraComment+Fixtures.swift
//  Parra
//
//  Created by Mick MacCallum on 12/17/24.
//

import Foundation

extension ParraComment: ParraFixture {
    static var redactedComment: ParraComment {
        return ParraComment(
            id: .uuid,
            createdAt: .now,
            updatedAt: .now,
            deletedAt: nil,
            body: "Some text that you should never see. If you do, report it please :)",
            userId: .uuid,
            feedItemId: .uuid,
            user: ParraUserStub(
                id: .uuid,
                tenantId: .uuid,
                name: "John Appleseed",
                displayName: "User 123456",
                avatar: nil,
                verified: true,
                roles: [
                    .init(id: .uuid, name: "Moderator", key: "mod")
                ]
            ),
            reactions: nil,
            isTemporary: nil
        )
    }

    public static func validStates() -> [ParraComment] {
        return [
            ParraComment(
                id: .uuid,
                createdAt: .now.daysAgo(0.01),
                updatedAt: .now.daysAgo(0.01),
                deletedAt: nil,
                body: "I love this content! Keep up the great work",
                userId: .uuid,
                feedItemId: .uuid,
                user: ParraUserStub(
                    id: .uuid,
                    tenantId: .uuid,
                    name: "Mick",
                    displayName: "User 123456",
                    avatar: ParraImageAsset(
                        id: .uuid,
                        size: CGSize(width: 4_284, height: 4_284),
                        url: URL(
                            string: "https://parra-cdn.com/users/9a311ff4-6af9-445e-a3df-6900787e2198/avatar/807a9033-0d1b-41d8-9102-3dc47f0c3e32.jpg"
                        )!
                    ),
                    verified: true,
                    roles: [
                        .init(id: .uuid, name: "Owner", key: "owner")
                    ]
                ),
                reactions: [
                    ParraReactionSummary(
                        id: .uuid,
                        firstReactionAt: .now.daysAgo(1),
                        name: "thumbs_up",
                        type: .emoji,
                        value: "👍",
                        count: 6,
                        reactionId: .uuid
                    ),
                    ParraReactionSummary(
                        id: .uuid,
                        firstReactionAt: .now.daysAgo(1),
                        name: "thumbs_down",
                        type: .emoji,
                        value: "👎",
                        count: 1,
                        reactionId: nil
                    ),
                    ParraReactionSummary(
                        id: .uuid,
                        firstReactionAt: .now.daysAgo(2),
                        name: "heart",
                        type: .emoji,
                        value: "❤️",
                        count: 42,
                        reactionId: nil
                    ),
                    ParraReactionSummary(
                        id: .uuid,
                        firstReactionAt: .now.daysAgo(3),
                        name: "celebrate",
                        type: .emoji,
                        value: "🥳",
                        count: 4,
                        reactionId: .uuid
                    )
                ],
                isTemporary: nil
            ),
            ParraComment(
                id: .uuid,
                createdAt: .now.daysAgo(0.15),
                updatedAt: .now.daysAgo(0.15),
                deletedAt: nil,
                body: "This is my favorite video yet. I love all the new stuff and the direction this channel has been going. Let's goooo!",
                userId: .uuid,
                feedItemId: .uuid,
                user: ParraUserStub(
                    id: .uuid,
                    tenantId: .uuid,
                    name: "Mick",
                    displayName: "User 123456",
                    avatar: ParraImageAsset(
                        id: .uuid,
                        size: CGSize(width: 4_284, height: 4_284),
                        url: URL(
                            string: "https://parra-cdn.com/users/9a311ff4-6af9-445e-a3df-6900787e2198/avatar/807a9033-0d1b-41d8-9102-3dc47f0c3e32.jpg"
                        )!
                    ),
                    verified: false,
                    roles: nil
                ),
                reactions: [
                    ParraReactionSummary(
                        id: .uuid,
                        firstReactionAt: .now,
                        name: "heart",
                        type: .emoji,
                        value: "❤️",
                        count: 4,
                        reactionId: .uuid
                    )
                ],
                isTemporary: true,
                submissionErrorMessage: "Your message contained inappropriate content"
            ),
            ParraComment(
                id: .uuid,
                createdAt: .now.daysAgo(1),
                updatedAt: .now.daysAgo(1),
                deletedAt: nil,
                body: "This is so cool!",
                userId: .uuid,
                feedItemId: .uuid,
                user: ParraUserStub(
                    id: .uuid,
                    tenantId: .uuid,
                    name: "Mick",
                    displayName: "User 123456",
                    avatar: ParraImageAsset(
                        id: .uuid,
                        size: CGSize(width: 4_284, height: 4_284),
                        url: URL(
                            string: "https://parra-cdn.com/users/9a311ff4-6af9-445e-a3df-6900787e2198/avatar/807a9033-0d1b-41d8-9102-3dc47f0c3e32.jpg"
                        )!
                    ),
                    verified: true,
                    roles: [
                        .init(id: .uuid, name: "Admin", key: "admin")
                    ]
                ),
                reactions: [
                    ParraReactionSummary(
                        id: .uuid,
                        firstReactionAt: .now,
                        name: "fire",
                        type: .emoji,
                        value: "🔥",
                        count: 65,
                        reactionId: .uuid
                    )
                ],
                isTemporary: nil
            )
        ]
    }

    public static func invalidStates() -> [ParraComment] {
        return []
    }
}
