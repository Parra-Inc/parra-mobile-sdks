//
//  Channel+Fixture.swift
//  Parra
//
//  Created by Mick MacCallum on 2/13/25.
//

import SwiftUI

extension Channel: ParraFixture {
    static var redactedChannel: Channel {
        return Channel(
            id: .uuid,
            createdAt: .now.daysAgo(1),
            updatedAt: .now.daysAgo(1),
            deletedAt: nil,
            tenantId: .uuid,
            type: .paidDm,
            status: .active,
            members: ParraUserStub.validStates().map { user in
                ChannelMember(
                    id: .uuid,
                    createdAt: .now.daysAgo(1),
                    updatedAt: .now.daysAgo(1),
                    deletedAt: nil,
                    user: user,
                    type: .tenantUser,
                    roles: [
                        .admin
                    ]
                )
            },
            latestMessages: Message.validStates()
        )
    }

    public static func validStates() -> [Channel] {
        return [
            Channel(
                id: .uuid,
                createdAt: .now.daysAgo(1),
                updatedAt: .now.daysAgo(1),
                deletedAt: nil,
                tenantId: .uuid,
                type: .paidDm,
                status: .active,
                members: ParraUserStub.validStates().map { user in
                    ChannelMember(
                        id: .uuid,
                        createdAt: .now.daysAgo(1),
                        updatedAt: .now.daysAgo(1),
                        deletedAt: nil,
                        user: user,
                        type: .tenantUser,
                        roles: [
                            .admin
                        ]
                    )
                },
                latestMessages: Message.validStates()
            ),
            Channel(
                id: .uuid,
                createdAt: .now.daysAgo(2),
                updatedAt: .now.daysAgo(2),
                deletedAt: nil,
                tenantId: .uuid,
                type: .paidDm,
                status: .active,
                members: ParraUserStub.validStates().dropLast().map { user in
                    ChannelMember(
                        id: .uuid,
                        createdAt: .now.daysAgo(2),
                        updatedAt: .now.daysAgo(2),
                        deletedAt: nil,
                        user: user,
                        type: .tenantUser,
                        roles: [
                            .guest
                        ]
                    )
                },
                latestMessages: Message.validStates()
            ),
            Channel(
                id: .uuid,
                createdAt: .now.daysAgo(3),
                updatedAt: .now.daysAgo(3),
                deletedAt: nil,
                tenantId: .uuid,
                type: .paidDm,
                status: .active,
                members: ParraUserStub.validStates().dropFirst().map { user in
                    ChannelMember(
                        id: .uuid,
                        createdAt: .now.daysAgo(3),
                        updatedAt: .now.daysAgo(3),
                        deletedAt: nil,
                        user: user,
                        type: .tenantUser,
                        roles: [
                            .member
                        ]
                    )
                },
                latestMessages: Message.validStates()
            )
        ]
    }
}
