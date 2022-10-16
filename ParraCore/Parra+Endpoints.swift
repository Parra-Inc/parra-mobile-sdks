//
//  Parra+Endpoints.swift
//  Core
//
//  Created by Mick MacCallum on 3/12/22.
//

import UIKit

public extension Parra {
    enum API {
        public static func getCards() async throws -> [ParraCardItem] {
            let cardsResponse: CardsResponse = try await Parra.shared.networkManager.performAuthenticatedRequest(
                route: "cards",
                method: .get,
                cachePolicy: .reloadIgnoringLocalAndRemoteCacheData
            )
            
            return cardsResponse.items
        }
        
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
