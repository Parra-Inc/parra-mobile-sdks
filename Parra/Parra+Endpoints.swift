//
//  Parra+Endpoints.swift
//  Parra
//
//  Created by Mick MacCallum on 3/12/22.
//

import UIKit

internal extension Parra {
    // MARK: - API
    enum API {
        // MARK: - Feedback API
        internal enum Feedback {
            /// Fetches all available Parra Feedback cards for the supplied app area. If `ParraQuestionAppArea.all` is provided
            /// cards from all app areas will be combined and returned.
            internal static func getCards(appArea: ParraQuestionAppArea) async throws -> [ParraCardItem] {
                var queryItems: [String: String] = [:]
                // It is important that an app area name is only provided if a specific one is meant to be returned.
                // If the app area type is `all` then there should not be a `app_area` key present in the request.
                if let appAreaName = appArea.parameterized {
                    queryItems["app_area_id"] = appAreaName
                }

                let response: AuthenticatedRequestResult<CardsResponse> = await Parra.shared.networkManager.performAuthenticatedRequest(
                    endpoint: .getCards,
                    queryItems: queryItems,
                    cachePolicy: .reloadIgnoringLocalAndRemoteCacheData
                )

                switch response.result {
                case .success(let cardsResponse):
                    return cardsResponse.items
                case .failure(let error):
                    parraLogError("Error fetching cards from Parra", error)

                    throw error
                }
            }

            /// Submits the provided list of CompleteCards as answers to the cards linked to them.
            internal static func bulkAnswerQuestions(cards: [CompletedCard]) async throws {
                if cards.isEmpty {
                    return
                }

                let response: AuthenticatedRequestResult<EmptyResponseObject> = await Parra.shared.networkManager.performAuthenticatedRequest(
                    endpoint: .postBulkAnswerQuestions,
                    cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
                    body: cards.map { CompletedCardUpload(completedCard: $0) }
                )

                switch response.result {
                case .success:
                    return
                case .failure(let error):
                    parraLogError("Error submitting card responses to Parra", error)

                    throw error
                }
            }

            /// Fetches the feedback form with the provided id from the Parra API.
            internal static func getFeedbackForm(with formId: String) async throws -> ParraFeedbackFormResponse {
                guard let escapedFormId = formId.addingPercentEncoding(
                    withAllowedCharacters: .urlPathAllowed
                ) else {
                    throw ParraError.message("Provided form id: \(formId) contains invalid characters. Must be URL path encodable.")
                }

                let response: AuthenticatedRequestResult<ParraFeedbackFormResponse> = await Parra.shared.networkManager.performAuthenticatedRequest(
                    endpoint: .getFeedbackForm(formId: escapedFormId)
                )

                switch response.result {
                case .success(let formResponse):
                    return formResponse
                case .failure(let error):
                    parraLogError("Error fetching feedback form from Parra", error)

                    throw error
                }
            }

            /// Submits the provided data as answers for the form with the provided id.
            internal static func submitFeedbackForm(
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
                    throw ParraError.message("Provided form id: \(formId) contains invalid characters. Must be URL path encodable.")
                }

                let response: AuthenticatedRequestResult<EmptyResponseObject> = await Parra.shared.networkManager.performAuthenticatedRequest(
                    endpoint: .postSubmitFeedbackForm(formId: escapedFormId),
                    body: body
                )

                switch response.result {
                case .success:
                    return
                case .failure(let error):
                    parraLogError("Error submitting form to Parra", error)

                    throw error
                }
            }
        }

        // MARK: - Sessions API
        internal enum Sessions {
            /// Uploads the provided sessions, failing outright if enough sessions fail to upload
            /// - Returns: A set of ids of the sessions that were successfully uploaded.
            @MainActor
            static func bulkSubmitSessions(sessions: [ParraSession]) async throws -> (Set<String>, ParraSessionsResponse?) {
                guard let tenantId = await ParraConfigState.shared.getCurrentState().tenantId else {
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
                    parraLogDebug("Uploading session: \(session.sessionId)")

                    let sessionUpload = ParraSessionUpload(session: session)

                    let response: AuthenticatedRequestResult<ParraSessionsResponse> = await Parra.shared.networkManager.performAuthenticatedRequest(
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
                        parraLogError(error)

                        // If any of the sessions fail to upload afty rerying, fail the entire operation
                        // returning the sessions that have been completed so far.
                        if response.attributes.contains(.exceededRetryLimit) {
                            return (completedSessions, sessionResponse)
                        }
                    }
                }

                return (completedSessions, sessionResponse)
            }
        }

        // MARK: - Push API
        internal enum Push {
            @MainActor
            static func uploadPushToken(token: String) async throws {
                guard let tenantId = await ParraConfigState.shared.getCurrentState().tenantId else {
                    throw ParraError.notInitialized
                }

                let body: [String: String] = [
                    "token": token,
                    "type": "apns"
                ]

                let response: AuthenticatedRequestResult<EmptyResponseObject> = await Parra.shared.networkManager.performAuthenticatedRequest(
                    endpoint: .postPushTokens(tenantId: tenantId),
                    body: body
                )

                switch response.result {
                case .success:
                    return
                case .failure(let error):
                    parraLogError("Error uploading device push token to Parra", error)

                    throw error
                }
            }
        }

        // MARK: - Assets API
        internal enum Assets {
            internal static func performBulkAssetCachingRequest(assets: [Asset]) async {
                await Parra.shared.networkManager.performBulkAssetCachingRequest(
                    assets: assets
                )
            }

            internal static func fetchAsset(asset: Asset) async throws -> UIImage? {
                return try await Parra.shared.networkManager.fetchAsset(
                    asset: asset
                )
            }

            internal static func isAssetCached(asset: Asset) async -> Bool {
                return await Parra.shared.networkManager.isAssetCached(
                    asset: asset
                )
            }
        }
    }
}
