//
//  API+purchases.swift
//  Parra
//
//  Created by Mick MacCallum on 11/12/24.
//

import Foundation

extension API {
    func getPaywall(
        for entitlement: String,
        context: String?
    ) async throws -> ParraAppPaywall {
        var queryItems: [String: String] = [
            "entitlement": entitlement
        ]

        if let context {
            queryItems["context"] = context
        }

        return try await hitEndpoint(
            .getPaywall,
            queryItems: queryItems,
            cachePolicy: .reloadIgnoringLocalAndRemoteCacheData
        )
    }

    func reportPurchase(with receipt: String) async throws
        -> ParraUserEntitlementsResponseBody
    {
        let body: [String: String] = [
            "apple_receipt": receipt
        ]

        return try await hitEndpoint(
            .postPurchases,
            config: .defaultWithRetries,
            body: body
        )
    }

    func reportPurchases(with receipts: [String]) async throws
        -> ParraUserEntitlementsResponseBody
    {
        let body: [String: [String]] = [
            "apple_receipts": receipts
        ]

        return try await hitEndpoint(
            .postPurchases,
            config: .defaultWithRetries,
            body: body
        )
    }
}
