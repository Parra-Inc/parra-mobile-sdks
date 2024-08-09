//
//  ParraImageButtonContent.swift
//  Parra
//
//  Created by Mick MacCallum on 3/4/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

public struct ParraImageButtonContent: Hashable, Equatable {
    // MARK: - Lifecycle

    public init(
        image: ParraImageContent,
        isDisabled: Bool = false
    ) {
        self.image = image
        self.isDisabled = isDisabled
    }

    // MARK: - Public

    public let image: ParraImageContent
    public internal(set) var isDisabled: Bool
}
