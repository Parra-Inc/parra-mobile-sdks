//
//  SegmentContent.swift
//  Parra
//
//  Created by Mick MacCallum on 2/29/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

public struct ParraSegmentContent {
    // MARK: - Lifecycle

    public init(
        options: [Option],
        optionSelected: ((Option) -> Void)? = nil,
        optionConfirmed: ((Option) -> Void)? = nil
    ) {
        self.options = options
        self.optionSelected = optionSelected
        self.optionConfirmed = optionConfirmed
    }

    // MARK: - Public

    public struct Option: Identifiable, Hashable {
        public let id: String

        /// The text to be shown in a label for this `Option`.
        public let text: String
    }

    public let options: [Option]
    public let optionSelected: ((Option) -> Void)?
    public let optionConfirmed: ((Option) -> Void)?
}
