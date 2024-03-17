//
//  ChangelogWidgetConfig.swift
//  Parra
//
//  Created by Mick MacCallum on 3/15/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

public class ChangelogWidgetConfig: ContainerConfig, Observable {
    // MARK: - Lifecycle

    public init(
        title: LabelConfig,
        releasePreviewNames: LabelConfig,
        releasePreviewDescriptions: LabelConfig,
        releasePreviewCreatedAts: LabelConfig,
        emptyStateView: EmptyStateConfig,
        errorStateView: EmptyStateConfig
    ) {
        self.title = title
        self.releasePreviewNames = releasePreviewNames
        self.releasePreviewDescriptions = releasePreviewDescriptions
        self.releasePreviewCreatedAts = releasePreviewCreatedAts
        self.emptyStateView = emptyStateView
        self.errorStateView = errorStateView
    }

    // MARK: - Public

    public static let `default` = ChangelogWidgetConfig(
        title: LabelConfig(fontStyle: .title),
        releasePreviewNames: LabelConfig(fontStyle: .headline),
        releasePreviewDescriptions: LabelConfig(fontStyle: .body),
        releasePreviewCreatedAts: LabelConfig(fontStyle: .caption),
        emptyStateView: .default,
        errorStateView: .errorDefault
    )

    public let title: LabelConfig
    public let releasePreviewNames: LabelConfig
    public let releasePreviewDescriptions: LabelConfig
    public let releasePreviewCreatedAts: LabelConfig
    public let emptyStateView: EmptyStateConfig
    public let errorStateView: EmptyStateConfig
}
