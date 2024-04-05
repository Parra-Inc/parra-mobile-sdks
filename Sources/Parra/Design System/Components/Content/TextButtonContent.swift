//
//  TextButtonContent.swift
//  Parra
//
//  Created by Mick MacCallum on 1/28/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

public struct TextButtonContent: Equatable, Hashable {
    // MARK: - Lifecycle

    public init(
        text: LabelContent,
        isDisabled: Bool = false
    ) {
        self.text = text
        self.isDisabled = isDisabled
    }

    // MARK: - Public

    public let text: LabelContent
    public let isDisabled: Bool
}
