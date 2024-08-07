//
//  API+feedback.swift
//  Parra
//
//  Created by Mick MacCallum on 5/1/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Foundation

extension API {
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
        data: [ParraFeedbackFormField: String]
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
}
