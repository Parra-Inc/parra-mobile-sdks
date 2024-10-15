//
//  ParraProductImage.swift
//  Parra
//
//  Created by Mick MacCallum on 10/1/24.
//

import Buy
import Parra
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
        self._size = _ParraSize(cgSize: size)
        self.url = url
    }

    public init(shopImage: Storefront.Image) {
        self.id = shopImage.id?.rawValue
        self.altText = shopImage.altText
        self.url = shopImage.url

        if let width = shopImage.width, let height = shopImage.height {
            self._size = _ParraSize(
                width: CGFloat(width),
                height: CGFloat(height)
            )
        } else {
            self._size = nil
        }
    }

    // MARK: - Public

    public let id: String?
    public let altText: String?
    public let _size: _ParraSize?
    public let url: URL

    public var size: CGSize? {
        return _size?.toCGSize
    }
}
