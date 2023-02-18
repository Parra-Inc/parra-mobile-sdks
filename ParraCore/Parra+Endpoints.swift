//
//  Parra+Endpoints.swift
//  Core
//
//  Created by Mick MacCallum on 3/12/22.
//

import UIKit

public extension Parra {
    enum API {
        /// Fetches all available Parra Feedback cards for the supplied app area. If `ParraQuestionAppArea.all` is provided
        /// cards from all app areas will be combined and returned.
        public static func getCards(appArea: ParraQuestionAppArea) async throws -> [ParraCardItem] {
            var queryItems: [String: String] = [:]
            // It is important that an app area name is only provided if a specific one is meant to be returned.
            // If the app area type is `all` then there should not be a `app_area` key present in the request.
            if let appAreaName = appArea.parameterized {
                queryItems["app_area_id"] = appAreaName
            }

            let response: AuthenticatedRequestResult<CardsResponse> = await Parra.shared.networkManager.performAuthenticatedRequest(
                route: "cards",
                method: .get,
                queryItems: queryItems,
                cachePolicy: .reloadIgnoringLocalAndRemoteCacheData
            )

            switch response.result {
            case .success(let cardsResponse):
                return cardsResponse.items
            case .failure(let error):
                throw error
            }
        }

        /// Submits the provided list of CompleteCards as answers to the cards linked to them.
        public static func bulkAnswerQuestions(cards: [CompletedCard]) async throws {
            if cards.isEmpty {
                return
            }

            let serializableCards = cards.map { $0.serializedForRequestBody() }

            let route = "bulk/questions/answer"

            let response: AuthenticatedRequestResult<EmptyResponseObject> = await Parra.shared.networkManager.performAuthenticatedRequest(
                route: route,
                method: .post,
                cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
                body: serializableCards
            )

            switch response.result {
            case .success:
                return
            case .failure(let error):
                throw error
            }
        }
    }

    internal enum Sessions {
        /// Uploads the provided sessions, failing outright if enough sessions fail to upload
        /// - Returns: A set of ids of the sessions that were successfully uploaded.
        static func bulkSubmitSessions(sessions: [ParraSession]) async throws -> Set<String> {
            guard let tenantId = Parra.config.tenantId else {
                throw ParraError.notInitialized
            }

            if sessions.isEmpty {
                return []
            }

            var completedSessions = Set<String>()
            let route = "tenants/\(tenantId)/sessions"
            for session in sessions {
                parraLogD("Uploading session: \(session.sessionId)")

                let sessionUpload = ParraSessionUpload(session: session)

                let response: AuthenticatedRequestResult<EmptyResponseObject> = await Parra.shared.networkManager.performAuthenticatedRequest(
                    route: route,
                    method: .post,
                    config: .defaultWithRetries,
                    body: sessionUpload
                )

                switch response.result {
                case .success:
                    completedSessions.insert(session.sessionId)
                case .failure(let error):
                    parraLogE(error)

                    // If any of the sessions fail to upload afty rerying, fail the entire operation
                    // returning the sessions that have been completed so far.
                    if response.attributes.contains(.exceededRetryLimit) {
                        return completedSessions
                    }
                }
            }

            return completedSessions
        }
    }

    enum Assets {
        public static func performBulkAssetCachingRequest(assets: [Asset]) async {
            await Parra.shared.networkManager.performBulkAssetCachingRequest(
                assets: assets
            )
        }

        public static func fetchAsset(asset: Asset) async throws -> UIImage? {
            return try await Parra.shared.networkManager.fetchAsset(
                asset: asset
            )
        }

        public static func isAssetCached(asset: Asset) -> Bool {
            return Parra.shared.networkManager.isAssetCached(
                asset: asset
            )
        }
    }
}
