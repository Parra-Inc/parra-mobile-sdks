//
//  ParraProductResponse.swift
//  Parra
//
//  Created by Mick MacCallum on 9/30/24.
//

import Buy
import SwiftUI

public struct ParraProductResponse {
    // MARK: - Lifecycle

    init(
        products: [ParraProduct],
        productPageInfo: PageInfo
    ) {
        self.products = products
        self.productPageInfo = productPageInfo
    }

    init(
        products: [Storefront.Product],
        productPageInfo: PageInfo
    ) {
        self.products = products.map { .init(shopProduct: $0) }
        self.productPageInfo = productPageInfo
    }

    init(
        products: [Storefront.ProductEdge],
        productPageInfo: PageInfo
    ) {
        self.products = products.map { .init(shopProduct: $0.node) }
        self.productPageInfo = productPageInfo
    }

    // MARK: - Public

    public struct PageInfo {
        let startCursor: String?
        let endCursor: String?
        let hasNextPage: Bool
    }

    public let products: [ParraProduct]
    public let productPageInfo: PageInfo
}
