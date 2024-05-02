//
//  API+roadmap.swift
//  Parra
//
//  Created by Mick MacCallum on 5/1/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Foundation

extension API {
    func getRoadmap() async throws -> AppRoadmapConfiguration {
        return try await hitEndpoint(
            .getRoadmap(
                tenantId: appState.tenantId,
                applicationId: appState.applicationId
            )
        )
    }

    func paginateTickets(
        limit: Int,
        offset: Int,
        filter: String
    ) async throws -> UserTicketCollectionResponse {
        return try await hitEndpoint(
            .getPaginateTickets(
                tenantId: appState.tenantId,
                applicationId: appState.applicationId
            ),
            queryItems: [
                "limit": String(limit),
                "offset": String(offset),
                "filter": filter
            ]
        )
    }

    func voteForTicket(
        with ticketId: String
    ) async -> AuthenticatedRequestResult<UserTicket> {
        return await apiResourceServer.hitApiEndpoint(
            endpoint: .postVoteForTicket(
                tenantId: appState.tenantId,
                ticketId: ticketId
            )
        )
    }

    func removeVoteForTicket(
        with ticketId: String
    ) async -> AuthenticatedRequestResult<UserTicket> {
        return await apiResourceServer.hitApiEndpoint(
            endpoint: .deleteVoteForTicket(
                tenantId: appState.tenantId,
                ticketId: ticketId
            )
        )
    }
}
