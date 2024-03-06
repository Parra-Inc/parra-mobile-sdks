//
//  ParraNetworkManager+Endpoints.swift
//  Parra
//
//  Created by Mick MacCallum on 3/12/22.
//

import UIKit

private let logger = Logger(category: "Endpoints")

extension ParraNetworkManager {
    // MARK: - Feedback

    func getCards(
        appArea: ParraQuestionAppArea
    ) async throws -> CardsResponse {
        var queryItems: [String: String] = [:]
        // It is important that an app area name is only provided if a specific
        // one is meant to be returned. If the app area type is `all` then there
        // should not be a `app_area` key present in the request.
        if let appAreaName = appArea.parameterized {
            queryItems["app_area_id"] = appAreaName
        }

        return try await hitEndpoint(
            .getCards,
            queryItems: queryItems,
            cachePolicy: .reloadIgnoringLocalAndRemoteCacheData
        )
    }

    /// Submits the provided list of CompleteCards as answers to the cards
    /// linked to them.
    func bulkAnswerQuestions(cards: [CompletedCard]) async throws {
        if cards.isEmpty {
            return
        }

        let _: EmptyResponseObject = try await hitEndpoint(
            .postBulkAnswerQuestions,
            cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
            body: cards.map { CompletedCardUpload(completedCard: $0) }
        )
    }

    /// Fetches the feedback form with the provided id from the Parra API.
    func getFeedbackForm(
        with formId: String
    ) async throws -> ParraFeedbackFormResponse {
        guard let escapedFormId = formId.addingPercentEncoding(
            withAllowedCharacters: .urlPathAllowed
        ) else {
            throw ParraError
                .message(
                    "Provided form id: \(formId) contains invalid characters. Must be URL path encodable."
                )
        }

        return try await hitEndpoint(
            .getFeedbackForm(formId: escapedFormId)
        )
    }

    /// Submits the provided data as answers for the form with the provided id.
    func submitFeedbackForm(
        with formId: String,
        data: [FeedbackFormField: String]
    ) async throws {
        // Map of FeedbackFormField.name -> a String (or value if applicable)
        let body = data.reduce([String: String]()) { partialResult, entry in
            var next = partialResult
            next[entry.key.name] = entry.value
            return next
        }

        guard let escapedFormId = formId.addingPercentEncoding(
            withAllowedCharacters: .urlPathAllowed
        ) else {
            throw ParraError
                .message(
                    "Provided form id: \(formId) contains invalid characters. Must be URL path encodable."
                )
        }

        let _: EmptyResponseObject = try await hitEndpoint(
            .postSubmitFeedbackForm(
                formId: escapedFormId
            ),
            body: body
        )
    }

    // MARK: - Sessions

    func submitSession(
        _ sessionUpload: ParraSessionUpload
    ) async -> AuthenticatedRequestResult<ParraSessionsResponse> {
        return await performAuthenticatedRequest(
            endpoint: .postBulkSubmitSessions(
                tenantId: appState.tenantId
            ),
            config: .defaultWithRetries,
            body: sessionUpload
        )
    }

    // MARK: - Push

    func uploadPushToken(token: String) async throws {
        let body: [String: String] = [
            "token": token,
            "type": "apns"
        ]

        let _: EmptyResponseObject = try await hitEndpoint(
            .postPushTokens(tenantId: appState.tenantId),
            body: body
        )
    }

    // MARK: - Roadmap

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
        filter: TicketFilter
    ) async throws -> UserTicketCollectionResponse {
        return try await hitEndpoint(
            .getPaginateTickets(
                tenantId: appState.tenantId,
                applicationId: appState.applicationId
            ),
            queryItems: [
                "limit": String(limit),
                "offset": String(offset),
                "filter": filter.paramName
            ]
        )
    }

    // MARK: - Private

    private func hitEndpoint<Response>(
        _ endpoint: ParraEndpoint,
        queryItems: [String: String] = [:],
        cachePolicy: URLRequest.CachePolicy? = nil,
        body: some Encodable = EmptyRequestObject()
    ) async throws -> Response where Response: Codable {
        let response: AuthenticatedRequestResult<Response> =
            await performAuthenticatedRequest(
                endpoint: endpoint,
                queryItems: queryItems,
                cachePolicy: cachePolicy,
                body: body
            )

        switch response.result {
        case .success(let response):
            return response
        case .failure(let error):
            throw error
        }
    }
}
