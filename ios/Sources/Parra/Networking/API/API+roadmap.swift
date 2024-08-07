//
//  API+roadmap.swift
//  Parra
//
//  Created by Mick MacCallum on 5/1/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Foundation

extension API {
    func getRoadmap() async throws -> ParraAppRoadmapConfiguration {
        return try await hitEndpoint(.getRoadmap)
    }

    func paginateTickets(
        limit: Int,
        offset: Int,
        filter: String
    ) async throws -> ParraUserTicketCollectionResponse {
        return try await hitEndpoint(
            .getPaginateTickets,
            queryItems: [
                "limit": String(limit),
                "offset": String(offset),
                "filter": filter
            ]
        )
    }

    func voteForTicket(
        with ticketId: String
    ) async -> AuthenticatedRequestResult<ParraUserTicket> {
        return await apiResourceServer.hitApiEndpoint(
            endpoint: .postVoteForTicket(
                ticketId: ticketId
            )
        )
    }

    func removeVoteForTicket(
        with ticketId: String
    ) async -> AuthenticatedRequestResult<ParraUserTicket> {
        return await apiResourceServer.hitApiEndpoint(
            endpoint: .deleteVoteForTicket(
                ticketId: ticketId
            )
        )
    }
}
