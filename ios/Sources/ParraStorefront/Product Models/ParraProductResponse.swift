//
//  ParraProductResponse.swift
//  Parra
//
//  Created by Mick MacCallum on 9/30/24.
//

import Buy
import Parra
import SwiftUI

public struct ParraProductResponse: Equatable {
    // MARK: - Lifecycle

    init(
        products: [ParraProduct],
        productPageInfo: PageInfo
    ) {
        self.products = PartiallyDecodableArray(products)
        self.productPageInfo = productPageInfo
    }

    init(
        products: [Storefront.Product],
        productPageInfo: PageInfo
    ) {
        self.products = PartiallyDecodableArray(
            products.map { ParraProduct(shopProduct: $0) }
        )
        self.productPageInfo = productPageInfo
    }

    init(
        products: [Storefront.ProductEdge],
        productPageInfo: PageInfo
    ) {
        self.products = PartiallyDecodableArray(
            products.map { ParraProduct(shopProduct: $0.node) }
        )
        self.productPageInfo = productPageInfo
    }

    // MARK: - Public

    public struct PageInfo: Equatable {
        let startCursor: String?
        let endCursor: String?
        let hasNextPage: Bool
    }

    public let products: PartiallyDecodableArray<ParraProduct>
    public let productPageInfo: PageInfo
}
