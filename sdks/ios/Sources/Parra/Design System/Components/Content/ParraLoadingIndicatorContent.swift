//
//  ParraLoadingIndicatorContent.swift
//  Parra
//
//  Created by Mick MacCallum on 6/21/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

public struct ParraLoadingIndicatorContent: Hashable, Equatable {
    // MARK: - Lifecycle

    public init(
        title: LabelContent,
        subtitle: LabelContent?,
        cancel: TextButtonContent?
    ) {
        self.title = title
        self.subtitle = subtitle
        self.cancel = cancel
    }

    // MARK: - Public

    public let title: LabelContent
    public let subtitle: LabelContent?
    public private(set) var cancel: TextButtonContent?
}
