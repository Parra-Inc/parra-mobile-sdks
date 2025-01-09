//
//  ParraImageButtonContent.swift
//  Parra
//
//  Created by Mick MacCallum on 3/4/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

public struct ParraImageButtonContent: Hashable, Equatable, Sendable {
    // MARK: - Lifecycle

    public init(
        image: ParraImageContent,
        isDisabled: Bool = false,
        isLoading: Bool = false
    ) {
        self.image = image
        self.isDisabled = isDisabled
        self.isLoading = isLoading
    }

    // MARK: - Public

    public let image: ParraImageContent
    public internal(set) var isDisabled: Bool
    public internal(set) var isLoading: Bool

    // MARK: - Internal

    func withDisabled(
        _ isDisabled: Bool
    ) -> ParraImageButtonContent {
        var copy = self

        copy.isDisabled = isDisabled

        return copy
    }

    func withLoading(
        _ isLoading: Bool
    ) -> ParraImageButtonContent {
        var copy = self

        copy.isLoading = isLoading
        copy.isDisabled = isLoading

        return copy
    }
}
