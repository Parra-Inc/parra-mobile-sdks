//
//  LabelContent.swift
//  Parra
//
//  Created by Mick MacCallum on 1/28/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI
import UIKit

public struct LabelContent: Hashable, Equatable {
    // MARK: - Lifecycle

    public init(
        text: String,
        icon: ImageContent? = nil
    ) {
        self.text = text
        self.icon = icon
    }

    public init?(text: String?) {
        guard let text else {
            return nil
        }

        self.text = text
        self.icon = nil
    }

    // MARK: - Public

    public let text: String
    public let icon: ImageContent?
}
