//
//  ChangelogWidgetConfig.swift
//  Parra
//
//  Created by Mick MacCallum on 3/15/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

public class ChangelogWidgetConfig: ContainerConfig {
    // MARK: - Lifecycle

    required init() {
        self.title = ChangelogWidgetConfig.default.title
        self.releasePreviewNames = ChangelogWidgetConfig.default
            .releasePreviewNames
        self.releasePreviewDescriptions = ChangelogWidgetConfig.default
            .releasePreviewDescriptions
        self.releasePreviewCreatedAts = ChangelogWidgetConfig.default
            .releasePreviewCreatedAts
        self.releaseDetailWhatsNew = ChangelogWidgetConfig.default
            .releaseDetailWhatsNew
        self.releaseDetailTitle = ChangelogWidgetConfig.default
            .releaseDetailTitle
        self.releaseDetailDescription = ChangelogWidgetConfig.default
            .releaseDetailDescription
        self.releaseDetailSectionTitle = ChangelogWidgetConfig.default
            .releaseDetailSectionTitle
        self.releaseDetailSectionItem = ChangelogWidgetConfig.default
            .releaseDetailSectionItem
        self.emptyStateView = ChangelogWidgetConfig.default.emptyStateView
        self.errorStateView = ChangelogWidgetConfig.default.errorStateView
    }

    public init(
        title: LabelConfig,
        releasePreviewNames: LabelConfig,
        releasePreviewDescriptions: LabelConfig,
        releasePreviewCreatedAts: LabelConfig,
        releaseDetailWhatsNew: LabelConfig,
        releaseDetailTitle: LabelConfig,
        releaseDetailDescription: LabelConfig,
        releaseDetailSectionTitle: LabelConfig,
        releaseDetailSectionItem: LabelConfig,
        emptyStateView: EmptyStateConfig,
        errorStateView: EmptyStateConfig
    ) {
        self.title = title
        self.releasePreviewNames = releasePreviewNames
        self.releasePreviewDescriptions = releasePreviewDescriptions
        self.releasePreviewCreatedAts = releasePreviewCreatedAts
        self.releaseDetailWhatsNew = releaseDetailWhatsNew
        self.releaseDetailTitle = releaseDetailTitle
        self.releaseDetailDescription = releaseDetailDescription
        self.releaseDetailSectionTitle = releaseDetailSectionTitle
        self.releaseDetailSectionItem = releaseDetailSectionItem
        self.emptyStateView = emptyStateView
        self.errorStateView = errorStateView
    }

    // MARK: - Public

    public static let `default` = ChangelogWidgetConfig(
        title: LabelConfig(fontStyle: .title),
        releasePreviewNames: LabelConfig(fontStyle: .headline),
        releasePreviewDescriptions: LabelConfig(fontStyle: .body),
        releasePreviewCreatedAts: LabelConfig(fontStyle: .caption),
        releaseDetailWhatsNew: LabelConfig(fontStyle: .largeTitle),
        releaseDetailTitle: LabelConfig(fontStyle: .title),
        releaseDetailDescription: LabelConfig(fontStyle: .body),
        releaseDetailSectionTitle: LabelConfig(fontStyle: .title2),
        releaseDetailSectionItem: LabelConfig(fontStyle: .body),
        emptyStateView: .default,
        errorStateView: .errorDefault
    )

    public let title: LabelConfig
    public let releasePreviewNames: LabelConfig
    public let releasePreviewDescriptions: LabelConfig
    public let releasePreviewCreatedAts: LabelConfig
    public let releaseDetailWhatsNew: LabelConfig
    public let releaseDetailTitle: LabelConfig
    public let releaseDetailDescription: LabelConfig
    public let releaseDetailSectionTitle: LabelConfig
    public let releaseDetailSectionItem: LabelConfig
    public let emptyStateView: EmptyStateConfig
    public let errorStateView: EmptyStateConfig
}