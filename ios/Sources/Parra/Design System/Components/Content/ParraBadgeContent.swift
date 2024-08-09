//
//  ParraBadgeContent.swift
//  Parra
//
//  Created by Mick MacCallum on 5/6/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Foundation

public struct ParraBadgeContent: Hashable, Equatable {
    // MARK: - Lifecycle

    public init(
        text: String,
        icon: ParraImageContent? = nil
    ) {
        self.text = text
        self.icon = icon
    }

    // MARK: - Public

    public internal(set) var text: String
    public internal(set) var icon: ParraImageContent?
}
