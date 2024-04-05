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
        self.releaseDetailTitle = nil
        self.releaseDetailSubtitle = nil
        self.releaseDetailDescription = nil
        self.releaseDetailSectionTitle = nil
        self.releaseDetailSectionItem = nil
        self.releaseDetailShowOtherReleasesButton = nil
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
        releaseDetailTitleBuilder: LocalComponentBuilder.Factory<
            Text,
            LabelConfig,
            LabelContent,
            LabelAttributes
        >? = nil,
        releaseDetailSubtitleBuilder: LocalComponentBuilder.Factory<
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
        releaseDetailSectionItemBuilder: LocalComponentBuilder.Factory<
            Text,
            LabelConfig,
            LabelContent,
            LabelAttributes
        >? = nil,
        releaseDetailShowOtherReleasesButtonBuilder: LocalComponentBuilder
            .ButtonFactory<
                Button<Text>,
                TextButtonConfig,
                TextButtonContent,
                TextButtonAttributes
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
        self.releaseDetailTitle = releaseDetailTitleBuilder
        self.releaseDetailSubtitle = releaseDetailSubtitleBuilder
        self.releaseDetailDescription = releaseDetailDescriptionBuilder
        self.releaseDetailSectionTitle = releaseDetailSectionTitleBuilder
        self.releaseDetailSectionItem = releaseDetailSectionItemBuilder
        self
            .releaseDetailShowOtherReleasesButton =
            releaseDetailShowOtherReleasesButtonBuilder
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
    public let releaseDetailTitle: LocalComponentBuilder.Factory<
        Text,
        LabelConfig,
        LabelContent,
        LabelAttributes
    >?
    public let releaseDetailSubtitle: LocalComponentBuilder.Factory<
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
    public let releaseDetailSectionItem: LocalComponentBuilder.Factory<
        Text,
        LabelConfig,
        LabelContent,
        LabelAttributes
    >?
    public let releaseDetailShowOtherReleasesButton: LocalComponentBuilder
        .ButtonFactory<
            Button<Text>,
            TextButtonConfig,
            TextButtonContent,
            TextButtonAttributes
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
