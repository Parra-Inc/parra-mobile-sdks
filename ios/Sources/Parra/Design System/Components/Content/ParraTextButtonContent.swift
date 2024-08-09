//
//  ParraTextButtonContent.swift
//  Parra
//
//  Created by Mick MacCallum on 1/28/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

public struct ParraTextButtonContent: Equatable, Hashable {
    // MARK: - Lifecycle

    public init(
        text: ParraLabelContent,
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
        self.text = ParraLabelContent(text: text)
        self.isDisabled = isDisabled
        self.isLoading = isLoading
    }

    // MARK: - Public

    public internal(set) var text: ParraLabelContent
    public internal(set) var isDisabled: Bool
    public internal(set) var isLoading: Bool

    // MARK: - Internal

    func withDisabled(
        _ isDisabled: Bool
    ) -> ParraTextButtonContent {
        var copy = self

        copy.isDisabled = isDisabled

        return copy
    }

    func withLoading(
        _ isLoading: Bool
    ) -> ParraTextButtonContent {
        var copy = self

        copy.isLoading = isLoading
        copy.isDisabled = isLoading

        return copy
    }
}
