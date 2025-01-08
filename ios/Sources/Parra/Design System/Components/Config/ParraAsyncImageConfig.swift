//
//  ParraAsyncImageConfig.swift
//  Parra
//
//  Created by Mick MacCallum on 1/8/25.
//

import SwiftUI

public struct ParraAsyncImageConfig: Equatable, Hashable, Sendable {
    // MARK: - Lifecycle

    public init(
        aspectRatio: CGFloat? = nil,
        contentMode: ContentMode = .fit,
        cachePolicy: URLRequest.CachePolicy = .useProtocolCachePolicy,
        timeoutInterval: TimeInterval = 60.0
    ) {
        self.aspectRatio = aspectRatio
        self.contentMode = contentMode
        self.cachePolicy = cachePolicy
        self.timeoutInterval = timeoutInterval
    }

    // MARK: - Public

    public let aspectRatio: CGFloat?
    public let contentMode: ContentMode
    public let cachePolicy: URLRequest.CachePolicy
    public let timeoutInterval: TimeInterval
}
