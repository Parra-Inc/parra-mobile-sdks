//
//  UserTicket+Fixtures.swift
//  Parra
//
//  Created by Mick MacCallum on 3/2/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Foundation

extension UserTicket: ParraFixture {
    static func validStates() -> [UserTicket] {
        return [
            UserTicket(
                id: UUID().uuidString,
                createdAt: .now,
                updatedAt: .now,
                deletedAt: nil,
                title: "The app crashes on the home screen",
                type: .bug,
                description: "When I launch the app and get to the home screen the app crashes and I have to restart it. This keeps happening and kind of sucks.",
                status: .open,
                displayStatus: .upcoming,
                displayStatusBadgeTitle: "In progress",
                voteCount: 69,
                votingEnabled: true,
                voted: false
            ),
            UserTicket(
                id: UUID().uuidString,
                createdAt: .now,
                updatedAt: .now,
                deletedAt: nil,
                title: "I can't add favorites",
                type: .bug,
                description: "Idk why but in a recent update the favotite button stopped working",
                status: .open,
                displayStatus: .inProgress,
                displayStatusBadgeTitle: "In progress",
                voteCount: 100_423,
                votingEnabled: true,
                voted: false
            ),
            UserTicket(
                id: UUID().uuidString,
                createdAt: .now,
                updatedAt: .now,
                deletedAt: nil,
                title: "Add more sort options",
                type: .improvement,
                description: nil,
                status: .open,
                displayStatus: .upcoming,
                displayStatusBadgeTitle: "In progress",
                voteCount: 1_150,
                votingEnabled: true,
                voted: false
            ),
            UserTicket(
                id: UUID().uuidString,
                createdAt: .now,
                updatedAt: .now,
                deletedAt: nil,
                title: "AI Copilot",
                type: .feature,
                description: "Hear me out... it would be sick if I could use an AI assistant to do my writing for me in this app like in others.",
                status: .open,
                displayStatus: .inProgress,
                displayStatusBadgeTitle: "In progress",
                voteCount: 420,
                votingEnabled: true,
                voted: false
            )
        ]
    }

    static func invalidStates() -> [UserTicket] {
        return []
    }
}
