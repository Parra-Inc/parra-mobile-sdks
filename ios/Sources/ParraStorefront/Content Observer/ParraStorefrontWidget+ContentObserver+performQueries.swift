//
//  ParraStorefrontWidget+ContentObserver+performQueries.swift
//  Parra
//
//  Created by Mick MacCallum on 10/8/24.
//

import Buy
import Foundation
import Parra

extension ParraStorefrontWidget.ContentObserver {
    func performQuery(
        _ query: Storefront.QueryRootQuery
    ) async throws -> Storefront.QueryRoot {
        return try await withCheckedThrowingContinuation { continuation in
            let task = client.queryGraphWith(query) { response, error in
                if let error {
                    continuation.resume(
                        throwing: error
                    )
                } else if let response {
                    continuation.resume(
                        returning: response
                    )
                } else {
                    continuation.resume(
                        throwing: ParraError.unknown
                    )
                }
            }

            task.resume()
        }
    }

    func performMutation(
        _ mutationQuery: Storefront.MutationQuery,
        rateLimit: TimeInterval = 4.0
    ) async throws -> Storefront.Mutation {
        let now = Date.now

        if let lastMutation {
            self.lastMutation = now

            let diff = now.timeIntervalSince(lastMutation)

            if diff < rateLimit {
                try await _Concurrency.Task.sleep(
                    for: .milliseconds(Int((rateLimit - diff) * 1_000))
                )
            }
        } else {
            lastMutation = now
        }

        return try await withCheckedThrowingContinuation { continuation in
            let task = client.mutateGraphWith(mutationQuery) { mutation, error in
                if let error {
                    continuation.resume(
                        throwing: error
                    )
                } else if let mutation {
                    continuation.resume(
                        returning: mutation
                    )
                } else {
                    continuation.resume(
                        throwing: ParraError.unknown
                    )
                }
            }

            task.resume()
        }
    }
}
