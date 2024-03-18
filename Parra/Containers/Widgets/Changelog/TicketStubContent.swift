//
//  TicketStubContent.swift
//  Parra
//
//  Created by Mick MacCallum on 3/18/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

struct TicketStubContent: Identifiable, Hashable {
    // MARK: - Lifecycle

    init(
        _ ticket: TicketStub
    ) {
        self.id = ticket.id
        self.ticketNumber = ticket.ticketNumber
        self.createdAt = LabelContent(
            text: ticket.createdAt.timeAgo(
                dateTimeStyle: .numeric
            )
        )
        self.type = ticket.type
        self.title = LabelContent(text: ticket.title)
        self.description = if let description = ticket.description {
            LabelContent(text: description)
        } else {
            nil
        }
        self.status = ticket.status
    }

    // MARK: - Internal

    /// Used in contexts where Ticket is rendered with placeholder
    /// redaction. Needs to be computed to have unique IDs for display in lists.
    static var redacted: TicketStubContent {
        return TicketStubContent(
            TicketStub(
                id: UUID().uuidString,
                createdAt: .now,
                updatedAt: .now,
                deletedAt: nil,
                title: "Easter egg bug report",
                shortTitle: nil,
                type: .bug,
                status: .inProgress,
                priority: .medium,
                description: "I was messing around with the source for this app when I found this and I probably should stop.",
                votingEnabled: false,
                isPublic: true,
                userNoteId: nil,
                estimatedStartDate: nil,
                estimatedCompletionDate: nil,
                icon: nil,
                ticketNumber: "23812",
                tenantId: UUID().uuidString,
                voteCount: 0,
                releasedAt: nil
            )
        )
    }

    let id: String
    let ticketNumber: String
    let createdAt: LabelContent
    let type: TicketType
    let title: LabelContent
    let description: LabelContent?
    let status: TicketStatus
}
