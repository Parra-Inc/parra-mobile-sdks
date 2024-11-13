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
        context: String? = nil
    ) async throws -> ParraApplePaywall {
        var body: [String: String] = [
            "entitlement": entitlement
        ]

        if let context {
            body["context"] = context
        }

        return try await hitEndpoint(
            .getPaywall,
            body: body
        )
    }

    func completePurchase(receipt: String) async throws
        -> ParraUserEntitlementsResponseBody
    {
        let body: [String: String] = [
            "receipt": receipt
        ]

        return try await hitEndpoint(
            .postPurchases,
            config: .defaultWithRetries,
            body: body
        )
    }
}
