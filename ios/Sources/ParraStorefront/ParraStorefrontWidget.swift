//
//  ParraStorefrontWidget.swift
//  Parra
//
//  Created by Mick MacCallum on 10/6/24.
//

import Parra
import SwiftUI

import Buy
import ShopifyCheckoutSheetKit

public struct ParraStorefrontWidget: View {
    // MARK: - Lifecycle

    public init() {
        let client = Graph.Client(
            shopDomain: "",
            apiKey: ""
        )

        client.cachePolicy = .cacheFirst(expireIn: 3_600)
        self.client = client
    }

    // MARK: - Public

    public var body: some View {
        Text("Hello, World!")
        Text(parraAuthState.user?.info.displayName ?? "idk")

        Button("Store stuff") {
            _Concurrency.Task {
                do {
                    let q = Storefront.buildQuery { $0
                        .product { $0
                        }
                    }
                    try await performQuery(q)
                } catch {}
            }
        }
    }

    // MARK: - Internal

    let client: Graph.Client

    @Environment(\.parra) var parra
    @Environment(\.parraAuthState) var parraAuthState

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
                    //                    continuation.resume(
                    //                        throwing:
                    //                    )
                }
            }

            task.resume()
        }
    }
}
