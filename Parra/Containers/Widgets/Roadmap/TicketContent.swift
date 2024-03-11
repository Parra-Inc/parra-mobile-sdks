//
//  TicketContent.swift
//  Parra
//
//  Created by Mick MacCallum on 3/6/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Foundation

protocol TicketContentDelegate {
    func ticketContentDidPressVote(
        _ ticketId: String
    )
}

struct TicketContent: Identifiable, Hashable {
    // MARK: - Lifecycle

    @MainActor
    init(
        _ userTicket: UserTicket,
        isVotingInProgress: Bool,
        delegate: TicketContentDelegate? = nil
    ) {
        self.originalTicket = userTicket
        self.isVotingInProgress = isVotingInProgress
        self.id = userTicket.id
        self.createdAt = LabelContent(
            text: userTicket.createdAt.timeAgo(
                dateTimeStyle: .numeric
            )
        )
        self.type = userTicket.type
        self.title = LabelContent(text: userTicket.title)
        self.description = if let description = userTicket.description {
            LabelContent(text: description)
        } else {
            nil
        }
        self.status = userTicket.status
        self.displayStatus = userTicket.displayStatus
        self
            .statusTitle = LabelContent(
                text: userTicket
                    .displayStatusBadgeTitle
            )
        self.votingEnabled = userTicket.votingEnabled
        self.voted = userTicket.voted
        self.voteCount = TicketContent.voteCountLabelContent(from: userTicket)
        self.voteButton = ImageButtonContent(
            image: .symbol("triangleshape.fill", .monochrome),
            isDisabled: isVotingInProgress,
            onPress: nil
        )

        voteButton.onPress = { [self] in
            delegate?.ticketContentDidPressVote(id)
        }
    }

    init(
        originalTicket: UserTicket,
        id: String,
        createdAt: LabelContent,
        type: TicketType,
        title: LabelContent,
        description: LabelContent?,
        status: TicketStatus,
        displayStatus: TicketDisplayStatus,
        statusTitle: LabelContent,
        votingEnabled: Bool,
        voted: Bool,
        voteCount: LabelContent,
        voteButton: ImageButtonContent,
        isVotingInProgress: Bool
    ) {
        self.originalTicket = originalTicket
        self.id = id
        self.createdAt = createdAt
        self.type = type
        self.title = title
        self.description = description
        self.status = status
        self.displayStatus = displayStatus
        self.statusTitle = statusTitle
        self.votingEnabled = votingEnabled
        self.voted = voted
        self.voteCount = voteCount
        self.voteButton = voteButton
        self.isVotingInProgress = isVotingInProgress
    }

    // MARK: - Internal

    /// Used in contexts where TicketContent is rendered with placeholder
    /// redaction. Needs to be computed to have unique IDs for display in lists.
    @MainActor static var redacted: TicketContent {
        return TicketContent(
            UserTicket(
                id: UUID().uuidString,
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
            ),
            isVotingInProgress: false
        )
    }

    let originalTicket: UserTicket
    let id: String
    let createdAt: LabelContent
    let type: TicketType
    let title: LabelContent
    let description: LabelContent?
    let status: TicketStatus
    let displayStatus: TicketDisplayStatus
    let statusTitle: LabelContent
    let votingEnabled: Bool
    let voted: Bool
    let voteCount: LabelContent
    var voteButton: ImageButtonContent
    private(set) var isVotingInProgress: Bool

    func withVoting(_ voting: Bool) -> TicketContent {
        let voteModifier = voted ? -1 : 1

        var ticket = originalTicket
        if voting {
            ticket.voteCount += voteModifier
        }

        let updatedVoteCount = TicketContent.voteCountLabelContent(
            from: ticket
        )

        let voted = voting ? !voted : voted

        return TicketContent(
            originalTicket: originalTicket,
            id: id,
            createdAt: createdAt,
            type: type,
            title: title,
            description: description,
            status: status,
            displayStatus: displayStatus,
            statusTitle: statusTitle,
            votingEnabled: votingEnabled,
            voted: voted,
            voteCount: updatedVoteCount,
            voteButton: voteButton,
            isVotingInProgress: voting
        )
    }

    // MARK: - Private

    private static func voteCountLabelContent(
        from userTicket: UserTicket
    ) -> LabelContent {
        return LabelContent(
            text: userTicket.voteCount.formatted(.number.notation(.compactName))
        )
    }
}
