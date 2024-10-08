//
//  ParraProductImage.swift
//  Parra
//
//  Created by Mick MacCallum on 10/1/24.
//

import Buy
import SwiftUI

public struct ParraProductImage: Equatable, Hashable, Codable {
    // MARK: - Lifecycle

    init(
        id: String? = nil,
        altText: String? = nil,
        size: CGSize? = nil,
        url: URL
    ) {
        self.id = id
        self.altText = altText
        self.size = size
        self.url = url
    }

    public init(shopImage: Storefront.Image) {
        self.id = shopImage.id?.rawValue
        self.altText = shopImage.altText
        self.url = shopImage.url

        if let width = shopImage.width, let height = shopImage.height {
            self.size = CGSize(
                width: CGFloat(width),
                height: CGFloat(height)
            )
        } else {
            self.size = nil
        }
    }

    // MARK: - Public

    public let id: String?
    public let altText: String?
    public let size: CGSize?
    public let url: URL
}
