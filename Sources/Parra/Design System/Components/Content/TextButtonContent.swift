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
        isDisabled: Bool = false,
        isLoading: Bool = false
    ) {
        self.text = text
        self.isDisabled = isDisabled
        self.isLoading = isLoading
    }

    public init(
        text: String,
        isDisabled: Bool = false,
        isLoading: Bool = false
    ) {
        self.text = LabelContent(text: text)
        self.isDisabled = isDisabled
        self.isLoading = isLoading
    }

    // MARK: - Public

    public internal(set) var text: LabelContent
    public internal(set) var isDisabled: Bool
    public internal(set) var isLoading: Bool
}
