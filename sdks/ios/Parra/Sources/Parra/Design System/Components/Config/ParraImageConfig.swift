//
//  ParraImageConfig.swift
//  Parra
//
//  Created by Mick MacCallum on 7/20/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

public struct ParraImageConfig: Equatable, Hashable, Sendable {
    // MARK: - Lifecycle

    public init(
        aspectRatio: CGFloat? = nil,
        contentMode: ContentMode = .fit
    ) {
        self.aspectRatio = aspectRatio
        self.contentMode = contentMode
    }

    // MARK: - Public

    public let aspectRatio: CGFloat?
    public let contentMode: ContentMode
}
