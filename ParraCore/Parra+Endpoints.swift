//
//  Parra+Endpoints.swift
//  Core
//
//  Created by Mick MacCallum on 3/12/22.
//

import UIKit

public extension Parra {
    enum API {
        /// <#Description#>
        /// - Parameter appArea: <#appArea description#>
        /// - Returns: <#description#>
        public static func getCards(appArea: ParraQuestionAppArea) async throws -> [ParraCardItem] {
            var queryItems: [String: String] = [:]
            // It is important that an app area name is only provided if a specific one is meant to be returned.
            // If the app area type is `all` then there should not be a `app_area` key present in the request.
            if let appAreaName = appArea.parameterized {
                queryItems["app_area_id"] = appAreaName
            }

            let cardsResponse: CardsResponse = try await Parra.shared.networkManager.performAuthenticatedRequest(
                route: "cards",
                method: .get,
                queryItems: queryItems,
                cachePolicy: .reloadIgnoringLocalAndRemoteCacheData
            )

            return cardsResponse.items
        }

        /// Submits the provided list of CompleteCards as answers to the cards linked to them.
        public static func bulkAnswerQuestions(cards: [CompletedCard]) async throws {
            if cards.isEmpty {
                return
            }
            
            let serializableCards = cards.map { $0.serializedForRequestBody() }

            let route = "bulk/questions/answer"

            let _: EmptyResponseObject = try await Parra.shared.networkManager.performAuthenticatedRequest(
                route: route,
                method: .post,
                cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
                body: serializableCards
            )
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
