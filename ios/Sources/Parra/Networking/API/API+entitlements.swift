//
//  API+entitlements.swift
//  Parra
//
//  Created by Mick MacCallum on 2/20/25.
//

extension API {
    func getUserEntitlements() async throws -> [ParraUserEntitlement] {
        return try await hitEndpoint(
            .listUserEntitlements
        )
    }
}
