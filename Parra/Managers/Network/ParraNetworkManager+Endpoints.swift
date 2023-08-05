//
//  ParraNetworkManager+Endpoints.swift
//  Parra
//
//  Created by Mick MacCallum on 3/12/22.
//

import UIKit

fileprivate let logger = Logger(category: "Endpoints")

internal extension ParraNetworkManager {
    // MARK: - Feedback

    func getCards(appArea: ParraQuestionAppArea) async throws -> [ParraCardItem] {
        var queryItems: [String : String] = [:]
        // It is important that an app area name is only provided if a specific one is meant to be returned.
        // If the app area type is `all` then there should not be a `app_area` key present in the request.
        if let appAreaName = appArea.parameterized {
            queryItems["app_area_id"] = appAreaName
        }

        let response: AuthenticatedRequestResult<CardsResponse> = await performAuthenticatedRequest(
            endpoint: .getCards,
            queryItems: queryItems,
            cachePolicy: .reloadIgnoringLocalAndRemoteCacheData
        )

        switch response.result {
        case .success(let cardsResponse):
            return cardsResponse.items
        case .failure(let error):
            logger.error("Error fetching cards from Parra", error)

            throw error
        }
    }

    /// Submits the provided list of CompleteCards as answers to the cards linked to them.
    func bulkAnswerQuestions(cards: [CompletedCard]) async throws {
        if cards.isEmpty {
            return
        }

        let response: AuthenticatedRequestResult<EmptyResponseObject> = await performAuthenticatedRequest(
            endpoint: .postBulkAnswerQuestions,
            cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
            body: cards.map { CompletedCardUpload(completedCard: $0) }
        )

        switch response.result {
        case .success:
            return
        case .failure(let error):
            logger.error("Error submitting card responses to Parra", error)

            throw error
        }
    }

    /// Fetches the feedback form with the provided id from the Parra API.
    func getFeedbackForm(with formId: String) async throws -> ParraFeedbackFormResponse {
        guard let escapedFormId = formId.addingPercentEncoding(
            withAllowedCharacters: .urlPathAllowed
        ) else {
            throw ParraError.message("Provided form id: \(formId) contains invalid characters. Must be URL path encodable.")
        }

        let response: AuthenticatedRequestResult<ParraFeedbackFormResponse> = await performAuthenticatedRequest(
            endpoint: .getFeedbackForm(formId: escapedFormId)
        )

        switch response.result {
        case .success(let formResponse):
            return formResponse
        case .failure(let error):
            logger.error("Error fetching feedback form from Parra", error)

            throw error
        }
    }

    /// Submits the provided data as answers for the form with the provided id.
    func submitFeedbackForm(
        with formId: String,
        data: [FeedbackFormField: String]
    ) async throws {
        // Map of FeedbackFormField.name -> a String (or value if applicable)
        let body = data.reduce([String : String]()) { partialResult, entry in
            var next = partialResult
            next[entry.key.name] = entry.value
            return next
        }

        guard let escapedFormId = formId.addingPercentEncoding(
            withAllowedCharacters: .urlPathAllowed
        ) else {
            throw ParraError.message("Provided form id: \(formId) contains invalid characters. Must be URL path encodable.")
        }

        let response: AuthenticatedRequestResult<EmptyResponseObject> = await performAuthenticatedRequest(
            endpoint: .postSubmitFeedbackForm(formId: escapedFormId),
            body: body
        )

        switch response.result {
        case .success:
            return
        case .failure(let error):
            logger.error("Error submitting form to Parra", error)

            throw error
        }
    }

    // MARK: - Sessions

    /// Uploads the provided sessions, failing outright if enough sessions fail to upload
    /// - Returns: A set of ids of the sessions that were successfully uploaded.
    func bulkSubmitSessions(
        sessions: [ParraSession]
    ) async throws -> (Set<String>, ParraSessionsResponse?) {
        guard let tenantId = await configState.getCurrentState().tenantId else {
            throw ParraError.notInitialized
        }

        if sessions.isEmpty {
            return ([], nil)
        }

        var completedSessions = Set<String>()
        // It's possible that multiple sessions that are uploaded could receive a response indicating that polling
        // should occur. If this happens, we'll honor the most recent of these.
        var sessionResponse: ParraSessionsResponse?
        for session in sessions {
            logger.debug("Uploading session: \(session.sessionId)")

            let sessionUpload = ParraSessionUpload(session: session)

            let response: AuthenticatedRequestResult<ParraSessionsResponse> = await performAuthenticatedRequest(
                    endpoint: .postBulkSubmitSessions(tenantId: tenantId),
                    config: .defaultWithRetries,
                    body: sessionUpload
                )

            switch response.result {
            case .success(let payload):
                // Don't override the session response unless it's another one with shouldPoll enabled.
                if payload.shouldPoll {
                    sessionResponse = payload
                }

                completedSessions.insert(session.sessionId)
            case .failure(let error):
                logger.error(error)

                // If any of the sessions fail to upload afty rerying, fail the entire operation
                // returning the sessions that have been completed so far.
                if response.attributes.contains(.exceededRetryLimit) {
                    return (completedSessions, sessionResponse)
                }
            }
        }

        return (completedSessions, sessionResponse)
    }

    // MARK: - Push

    func uploadPushToken(token: String) async throws {
        guard let tenantId = await configState.getCurrentState().tenantId else {
            throw ParraError.notInitialized
        }

        let body: [String : String] = [
            "token": token,
            "type": "apns"
        ]

        let response: AuthenticatedRequestResult<EmptyResponseObject> = await performAuthenticatedRequest(
            endpoint: .postPushTokens(tenantId: tenantId),
            body: body
        )

        switch response.result {
        case .success:
            return
        case .failure(let error):
            logger.error("Error uploading device push token to Parra", error)

            throw error
        }
    }
}
