//
//  UserTicket+Fixtures.swift
//  Parra
//
//  Created by Mick MacCallum on 3/2/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Foundation

// MARK: - UserTicket + ParraFixture

extension ParraUserTicket: ParraFixture {
    static func validStates() -> [ParraUserTicket] {
        return [
            ParraUserTicket(
                id: UUID().uuidString,
                ticketNumber: "PAR-2349",
                createdAt: .now.daysAgo(0.01),
                updatedAt: .now.daysAgo(1.3),
                deletedAt: nil,
                title: "The app crashes on the home screen",
                type: .bug,
                description: "When I launch the app and get to the home screen the app crashes and I have to restart it. This keeps happening and kind of sucks.",
                status: .open,
                displayStatus: .inProgress,
                displayStatusBadgeTitle: "in progress",
                voteCount: 69,
                votingEnabled: true,
                voted: false
            ),
            ParraUserTicket(
                id: UUID().uuidString,
                ticketNumber: "PAR-4",
                createdAt: .now.daysAgo(8),
                updatedAt: .now.daysAgo(6),
                deletedAt: nil,
                title: "I can't add favorites",
                type: .bug,
                description: "Idk why but in a recent update the favotite button stopped working",
                status: .open,
                displayStatus: .live,
                displayStatusBadgeTitle: "fixed",
                voteCount: 100_423,
                votingEnabled: false,
                voted: false
            ),
            ParraUserTicket(
                id: UUID().uuidString,
                ticketNumber: "PAR-991011",
                createdAt: .now.daysAgo(30),
                updatedAt: .now.daysAgo(15),
                deletedAt: nil,
                title: "Add more sort options",
                type: .improvement,
                description: nil,
                status: .open,
                displayStatus: .inProgress,
                displayStatusBadgeTitle: "in progress",
                voteCount: 1_150,
                votingEnabled: true,
                voted: true
            ),
            ParraUserTicket(
                id: UUID().uuidString,
                ticketNumber: "PAR-3493929892",
                createdAt: .now.daysAgo(100),
                updatedAt: .now.daysAgo(75),
                deletedAt: nil,
                title: "AI Copilot",
                type: .feature,
                description: "Hear me out... it would be sick if I could use an AI assistant to do my writing for me in this app like in others.",
                status: .open,
                displayStatus: .inProgress,
                displayStatusBadgeTitle: "in progress",
                voteCount: 420,
                votingEnabled: true,
                voted: false
            )
        ]
    }

    static func invalidStates() -> [ParraUserTicket] {
        return []
    }
}
