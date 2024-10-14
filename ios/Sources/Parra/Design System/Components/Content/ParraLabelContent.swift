//
//  ParraLabelContent.swift
//  Parra
//
//  Created by Mick MacCallum on 1/28/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI
import UIKit

public struct ParraLabelContent: Hashable, Equatable, Sendable {
    // MARK: - Lifecycle

    public init(
        text: String,
        icon: ParraImageContent? = nil,
        isLoading: Bool = false
    ) {
        self.text = text
        self.icon = icon
        self.isLoading = isLoading
    }

    public init?(text: String?) {
        guard let text else {
            return nil
        }

        self.text = text
        self.icon = nil
        self.isLoading = false
    }

    // MARK: - Public

    public internal(set) var text: String
    public internal(set) var icon: ParraImageContent?
    public internal(set) var isLoading: Bool
}
