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
        blurContent: Bool = false,
        showBlurHash: Bool = true,
        showFailureIndicator: Bool = true,
        showLoadingIndicator: Bool = true,
        cachePolicy: URLRequest.CachePolicy = .useProtocolCachePolicy,
        timeoutInterval: TimeInterval = 60.0
    ) {
        self.aspectRatio = aspectRatio
        self.contentMode = contentMode
        self.blurContent = blurContent
        self.showBlurHash = showBlurHash
        self.showFailureIndicator = showFailureIndicator
        self.showLoadingIndicator = showLoadingIndicator
        self.cachePolicy = cachePolicy
        self.timeoutInterval = timeoutInterval
    }

    // MARK: - Public

    public let aspectRatio: CGFloat?
    public let contentMode: ContentMode
    public let blurContent: Bool
    public let showBlurHash: Bool
    public let showFailureIndicator: Bool
    public let showLoadingIndicator: Bool
    public let cachePolicy: URLRequest.CachePolicy
    public let timeoutInterval: TimeInterval
}
