//
//  RoadmapWidget+ContentObserver+Voting.swift
//  Parra
//
//  Created by Mick MacCallum on 3/11/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

extension RoadmapWidget.ContentObserver: TicketContentDelegate {
    // MARK: - TicketContentDelegate

    @MainActor
    func ticketContentDidPressVote(
        _ ticketId: String
    ) {
        let data = ticketPaginator.currentData()

        guard let ticket = data.items.first(
            where: { $0.id == ticketId }
        ) else {
            return
        }

        guard !ticket.isVotingInProgress else {
            Logger.warn(
                "Tapped vote button when vote operation is already in progress",
                [
                    "ticketId": ticketId
                ]
            )

            return
        }

        Task {
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
                    "ticketId": ticketId
                ])

                setVotingState(voting: false, for: ticket)
            }
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
            print(response)

            let updatedTicket = TicketContent(
                response,
                isVotingInProgress: false,
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
