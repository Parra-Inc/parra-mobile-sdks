//
//  ChangelogWidgetBuilderConfig.swift
//  Parra
//
//  Created by Mick MacCallum on 3/15/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

public class ChangelogWidgetBuilderConfig: LocalComponentBuilderConfig {
    // MARK: - Lifecycle

    public required init() {
        self.title = nil
        self.releasePreviewNames = nil
        self.releasePreviewVersions = nil
        self.releasePreviewDescriptions = nil
        self.releasePreviewCreatedAts = nil
        self.releaseDetailWhatsNew = nil
        self.releaseDetailTitle = nil
        self.releaseDetailVersion = nil
        self.releaseDetailDescription = nil
        self.releaseDetailSectionTitle = nil
        self.emptyStateView = nil
        self.errorStateView = nil
    }

    public init(
        titleBuilder: LocalComponentBuilder.Factory<
            Text,
            LabelConfig,
            LabelContent,
            LabelAttributes
        >? = nil,
        releasePreviewNamesBuilder: LocalComponentBuilder.Factory<
            Text,
            LabelConfig,
            LabelContent,
            LabelAttributes
        >? = nil,
        releasePreviewVersionsBuilder: LocalComponentBuilder.Factory<
            Text,
            LabelConfig,
            LabelContent,
            LabelAttributes
        >? = nil,
        releasePreviewDescriptionsBuilder: LocalComponentBuilder.Factory<
            Text,
            LabelConfig,
            LabelContent,
            LabelAttributes
        >? = nil,
        releasePreviewCreatedAtsBuilder: LocalComponentBuilder.Factory<
            Text,
            LabelConfig,
            LabelContent,
            LabelAttributes
        >? = nil,
        releaseDetailWhatsNewBuilder: LocalComponentBuilder.Factory<
            Text,
            LabelConfig,
            LabelContent,
            LabelAttributes
        >? = nil,
        releaseDetailTitleBuilder: LocalComponentBuilder.Factory<
            Text,
            LabelConfig,
            LabelContent,
            LabelAttributes
        >? = nil,
        releaseDetailVersionBuilder: LocalComponentBuilder.Factory<
            Text,
            LabelConfig,
            LabelContent,
            LabelAttributes
        >? = nil,
        releaseDetailDescriptionBuilder: LocalComponentBuilder.Factory<
            Text,
            LabelConfig,
            LabelContent,
            LabelAttributes
        >? = nil,
        releaseDetailSectionTitleBuilder: LocalComponentBuilder.Factory<
            Text,
            LabelConfig,
            LabelContent,
            LabelAttributes
        >? = nil,
        emptyStateViewBuilder: LocalComponentBuilder.Factory<
            AnyView,
            EmptyStateConfig,
            EmptyStateContent,
            EmptyStateAttributes
        >? = nil,
        errorStateViewBuilder: LocalComponentBuilder.Factory<
            AnyView,
            EmptyStateConfig,
            EmptyStateContent,
            EmptyStateAttributes
        >? = nil
    ) {
        self.title = titleBuilder
        self.releasePreviewNames = releasePreviewNamesBuilder
        self.releasePreviewVersions = releasePreviewVersionsBuilder
        self.releasePreviewDescriptions = releasePreviewDescriptionsBuilder
        self.releasePreviewCreatedAts = releasePreviewCreatedAtsBuilder
        self.releaseDetailWhatsNew = releaseDetailWhatsNewBuilder
        self.releaseDetailTitle = releaseDetailTitleBuilder
        self.releaseDetailVersion = releaseDetailVersionBuilder
        self.releaseDetailDescription = releaseDetailDescriptionBuilder
        self.releaseDetailSectionTitle = releaseDetailSectionTitleBuilder
        self.emptyStateView = emptyStateViewBuilder
        self.errorStateView = errorStateViewBuilder
    }

    // MARK: - Public

    public let title: LocalComponentBuilder.Factory<
        Text,
        LabelConfig,
        LabelContent,
        LabelAttributes
    >?
    public let releasePreviewNames: LocalComponentBuilder.Factory<
        Text,
        LabelConfig,
        LabelContent,
        LabelAttributes
    >?
    public let releasePreviewVersions: LocalComponentBuilder.Factory<
        Text,
        LabelConfig,
        LabelContent,
        LabelAttributes
    >?
    public let releasePreviewDescriptions: LocalComponentBuilder.Factory<
        Text,
        LabelConfig,
        LabelContent,
        LabelAttributes
    >?
    public let releasePreviewCreatedAts: LocalComponentBuilder.Factory<
        Text,
        LabelConfig,
        LabelContent,
        LabelAttributes
    >?
    public let releaseDetailWhatsNew: LocalComponentBuilder.Factory<
        Text,
        LabelConfig,
        LabelContent,
        LabelAttributes
    >?
    public let releaseDetailTitle: LocalComponentBuilder.Factory<
        Text,
        LabelConfig,
        LabelContent,
        LabelAttributes
    >?
    public let releaseDetailVersion: LocalComponentBuilder.Factory<
        Text,
        LabelConfig,
        LabelContent,
        LabelAttributes
    >?
    public let releaseDetailDescription: LocalComponentBuilder.Factory<
        Text,
        LabelConfig,
        LabelContent,
        LabelAttributes
    >?
    public let releaseDetailSectionTitle: LocalComponentBuilder.Factory<
        Text,
        LabelConfig,
        LabelContent,
        LabelAttributes
    >?
    public let emptyStateView: LocalComponentBuilder.Factory<
        AnyView,
        EmptyStateConfig,
        EmptyStateContent,
        EmptyStateAttributes
    >?
    public let errorStateView: LocalComponentBuilder.Factory<
        AnyView,
        EmptyStateConfig,
        EmptyStateContent,
        EmptyStateAttributes
    >?
}
