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
    ) async throws -> [ParraCardItem] {
        var queryItems: [String: String] = [:]
        // It is important that an app area name is only provided if a specific
        // one is meant to be returned. If the app area type is `all` then there
        // should not be a `app_area` key present in the request.
        if let appAreaName = appArea.parameterized {
            queryItems["app_area_id"] = appAreaName
        }

        let response: AuthenticatedRequestResult<CardsResponse> =
            await performAuthenticatedRequest(
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

    /// Submits the provided list of CompleteCards as answers to the cards
    /// linked to them.
    func bulkAnswerQuestions(cards: [CompletedCard]) async throws {
        if cards.isEmpty {
            return
        }

        let response: AuthenticatedRequestResult<EmptyResponseObject> =
            await performAuthenticatedRequest(
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

        let response: AuthenticatedRequestResult<ParraFeedbackFormResponse> =
            await performAuthenticatedRequest(
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

        let response: AuthenticatedRequestResult<EmptyResponseObject> =
            await performAuthenticatedRequest(
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

    func submitSession(
        _ sessionUpload: ParraSessionUpload
    ) async throws -> AuthenticatedRequestResult<ParraSessionsResponse> {
        let response: AuthenticatedRequestResult<ParraSessionsResponse> =
            await performAuthenticatedRequest(
                endpoint: .postBulkSubmitSessions(
                    tenantId: appState.tenantId
                ),
                config: .defaultWithRetries,
                body: sessionUpload
            )

        return response
    }

    // MARK: - Push

    func uploadPushToken(token: String) async throws {
        let body: [String: String] = [
            "token": token,
            "type": "apns"
        ]

        let response: AuthenticatedRequestResult<EmptyResponseObject> =
            await performAuthenticatedRequest(
                endpoint: .postPushTokens(tenantId: appState.tenantId),
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
