//
//  TicketContent.swift
//  Parra
//
//  Created by Mick MacCallum on 3/6/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Foundation

protocol TicketContentDelegate {
    @MainActor
    func ticketContentDidReceiveVote(_ ticketContent: TicketContent)

    @MainActor
    func ticketContentDidRemoveVote(_ ticketContent: TicketContent)
}

struct TicketContent: Identifiable, Hashable {
    // MARK: - Lifecycle

    @MainActor
    init(
        _ userTicket: UserTicket,
        delegate: TicketContentDelegate? = nil
    ) {
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
        self.voteCount = LabelContent(
            text: userTicket.voteCount.formatted(.number.notation(.compactName))
        )
        self.voteButton = ImageButtonContent(
            image: .symbol("triangleshape.fill", .monochrome),
            isDisabled: !votingEnabled,
            onPress: nil
        )

        voteButton.onPress = { [self] in
            if voted {
                delegate?.ticketContentDidRemoveVote(self)
            } else {
                delegate?.ticketContentDidReceiveVote(self)
            }
        }
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
            )
        )
    }

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
}
