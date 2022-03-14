//
//  Parra+Endpoints.swift
//  Core
//
//  Created by Mick MacCallum on 3/12/22.
//

import Foundation

public extension Parra {
    enum API {
        public static func getCards() async throws -> [CardItem] {
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
}
