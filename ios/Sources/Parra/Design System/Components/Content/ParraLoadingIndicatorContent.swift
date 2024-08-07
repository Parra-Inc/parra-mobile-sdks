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
        title: ParraLabelContent,
        subtitle: ParraLabelContent?,
        cancel: ParraTextButtonContent?
    ) {
        self.title = title
        self.subtitle = subtitle
        self.cancel = cancel
    }

    // MARK: - Public

    public let title: ParraLabelContent
    public let subtitle: ParraLabelContent?
    public private(set) var cancel: ParraTextButtonContent?

    public static let `default` = ParraLoadingIndicatorContent(
        title: ParraLabelContent(text: "Loading..."),
        subtitle: nil,
        cancel: nil
    )

    public static let `defaultWithCancel` = ParraLoadingIndicatorContent(
        title: ParraLabelContent(text: "Loading..."),
        subtitle: nil,
        cancel: .init(text: "Cancel")
    )
}
