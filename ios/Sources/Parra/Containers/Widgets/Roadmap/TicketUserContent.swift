//
//  TicketUserContent.swift
//  Parra
//
//  Created by Mick MacCallum on 3/6/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Foundation

struct TicketUserContent: Identifiable, Hashable {
    // MARK: - Lifecycle

    init(
        _ userTicket: ParraUserTicket
    ) {
        self.originalTicket = userTicket
        self.id = userTicket.id
        self.ticketNumber = userTicket.ticketNumber
        self.createdAt = ParraLabelContent(
            text: userTicket.createdAt.timeAgo(
                dateTimeStyle: .numeric,
                unitStyle: .short
            )
        )
        self.type = userTicket.type
        self.title = ParraLabelContent(text: userTicket.title)
        self.description = if let description = userTicket.description {
            ParraLabelContent(text: description)
        } else {
            nil
        }
        self.status = userTicket.status
        self.displayStatus = userTicket.displayStatus
        self.statusTitle = userTicket.displayStatusBadgeTitle
        self.votingEnabled = userTicket.votingEnabled
        self.voted = userTicket.voted
        self.voteCountRaw = userTicket.voteCount
        self.voteCount = TicketUserContent.voteCountLabelContent(
            from: userTicket.voteCount
        )
        self.voteButton = ParraImageButtonContent(
            image: .symbol("triangleshape.fill", .monochrome),
            isDisabled: false
        )
    }

    // MARK: - Internal

    /// Used in contexts where TicketContent is rendered with placeholder
    /// redaction. Needs to be computed to have unique IDs for display in lists.
    static var redacted: TicketUserContent {
        return TicketUserContent(
            ParraUserTicket(
                id: UUID().uuidString,
                ticketNumber: "23812",
                createdAt: .now,
                updatedAt: .now,
                deletedAt: nil,
                title: "Easter egg bug report",
                type: .bug,
                description: "I was messing around with the source for this app when I found this and I probably should stop.",
                status: .inProgress,
                displayStatus: .inProgress,
                displayStatusBadgeTitle: "In progress",
                voteCount: 100,
                votingEnabled: false,
                voted: true
            )
        )
    }

    let originalTicket: ParraUserTicket
    let id: String
    let ticketNumber: String
    let createdAt: ParraLabelContent
    let type: ParraTicketType
    let title: ParraLabelContent
    let description: ParraLabelContent?
    let status: ParraTicketStatus
    let displayStatus: ParraTicketDisplayStatus
    let statusTitle: String
    let votingEnabled: Bool
    private(set) var voted: Bool
    private(set) var voteCount: ParraLabelContent
    let voteButton: ParraImageButtonContent

    func withVoteToggled() -> TicketUserContent {
        let previouslyVoted = voted
        let previousVoteCount = voteCountRaw

        let voteModifier = previouslyVoted ? -1 : 1
        let newVoteCount = previousVoteCount + voteModifier

        var next = self

        next.voted = !previouslyVoted
        next.voteCount = TicketUserContent.voteCountLabelContent(
            from: newVoteCount
        )
        next.voteCountRaw = newVoteCount

        return next
    }

    // MARK: - Private

    // Keep another copy of the vote count as an int for transform operations
    // when voting/unvoting happens without having to modify the originalTicket
    // to keep track.
    private var voteCountRaw: Int

    private static func voteCountLabelContent(
        from voteCount: Int
    ) -> ParraLabelContent {
        return ParraLabelContent(
            text: voteCount.formatted(.number.notation(.compactName))
        )
    }
}
