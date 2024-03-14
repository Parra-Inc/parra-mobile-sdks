//
//  RoadmapWidget+ContentObserver+Voting.swift
//  Parra
//
//  Created by Mick MacCallum on 3/11/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Combine
import SwiftUI

extension RoadmapWidget.ContentObserver {
    func toggleVote(for ticketId: String?) -> String? {
        guard let ticketId else {
            return nil
        }

        // Fetch the most up to date version of the ticket.
        guard let ticket = ticketPaginator.items.first(
            where: { $0.id == ticketId }
        ) else {
            return nil
        }

        toggleVote(for: ticket)

        return ticketId
    }

    @MainActor
    func submitUpdatedVote(for ticketId: String?) async {
        guard let ticketId else {
            return
        }

        // Fetch the most up to date version of the ticket.
        guard let ticket = ticketPaginator.items.first(
            where: { $0.id == ticketId }
        ) else {
            return
        }

        // The user may have tapped the vote button an arbitrary number of times
        // and we only want to make a request to update their vote if it ends
        // different from where it started.
        guard ticket.originalTicket.voted != ticket.voted else {
            return
        }

        do {
            // If these throw, voting state is reset in catch. If they don't
            // the vote response handler will reset the state if there are
            // other issues. If nothing goes wrong, the voting state will be
            // resetto false when the updated ticket is received and
            // replaces the old one.
            // `voted` is what was toggled locally, so it is the state we want
            // to be in.
            if ticket.voted {
                try await ticketContentDidReceiveVote(ticket)
            } else {
                try await ticketContentDidRemoveVote(ticket)
            }
        } catch {
            Logger.error("Error toggling vote for ticket", error, [
                "ticketId": ticket.id
            ])

            toggleVote(for: ticket)
        }
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
            replaceTicket(
                with: TicketContent(response)
            )
        case .failure(let error):
            throw error
        }
    }

    @MainActor
    private func toggleVote(
        for content: TicketContent
    ) {
        replaceTicket(
            with: content.withVoteToggled()
        )
    }

    @MainActor
    private func replaceTicket(
        with content: TicketContent
    ) {
        ticketPaginator.updateItem(content)

        updateTicketOnAllTabs(content)
    }
}
