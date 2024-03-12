//
//  RoadmapWidget+ContentObserver+Voting.swift
//  Parra
//
//  Created by Mick MacCallum on 3/11/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Combine
import SwiftUI

extension RoadmapWidget.ContentObserver: TicketContentDelegate {
    @MainActor
    func processVote(for ticketId: String?) async {
        guard let ticketId else {
            return
        }

        // Fetch the most up to date version of the ticket.
        guard let ticket = ticketPaginator.items.first(
            where: { $0.id == ticketId }
        ) else {
            return
        }

        setVotingState(voting: true, for: ticket)

        do {
            // If these throw, voting state is reset in catch. If they don't
            // the vote response handler will reset the state if there are
            // other issues. If nothing goes wrong, the voting state will be
            // resetto false when the updated ticket is received and
            // replaces the old one.
            if ticket.voted {
                try await ticketContentDidRemoveVote(ticket)
            } else {
                try await ticketContentDidReceiveVote(ticket)
            }
        } catch {
            Logger.error("Error toggling vote for ticket", error, [
                "ticketId": ticket.id
            ])

            setVotingState(voting: false, for: ticket)
        }
    }

    // MARK: - TicketContentDelegate

    @MainActor
    func ticketContentDidPressVote(
        _ ticketId: String
    ) {
        currentTicketToVote = ticketId
    }

    func ticketContentDidReceiveVote(
        _ ticketContent: TicketContent
    ) async throws {
        let response = await networkManager.voteForTicket(
            with: ticketContent.id
        )

        try handleVoteResponse(
            for: ticketContent,
            response: response
        )
    }

    func ticketContentDidRemoveVote(
        _ ticketContent: TicketContent
    ) async throws {
        let response = await networkManager.removeVoteForTicket(
            with: ticketContent.id
        )

        try handleVoteResponse(
            for: ticketContent,
            response: response
        )
    }

    func handleVoteResponse(
        for ticket: TicketContent,
        response: AuthenticatedRequestResult<UserTicket>
    ) throws {
        if response.context.statusCode == 409 {
            // User had already removed their vote for this ticket
            Logger.warn(
                "Ignoring vote for ticket. Vote change causes no update",
                [
                    "ticketId": ticket.id
                ]
            )

            return
        }

        switch response.result {
        case .success(let response):
            let updatedTicket = TicketContent(
                response,
                delegate: self
            )

            replaceTicket(with: updatedTicket)
        case .failure(let error):
            throw error
        }
    }

    @MainActor
    private func setVotingState(
        voting: Bool,
        for content: TicketContent
    ) {
        let updated = content.withVoting(voting)

        replaceTicket(with: updated)
    }

    @MainActor
    private func replaceTicket(
        with content: TicketContent
    ) {
        ticketPaginator.updateItem(content)
    }
}
