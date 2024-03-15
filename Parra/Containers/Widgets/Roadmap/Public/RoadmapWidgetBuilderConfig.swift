//
//  RoadmapWidgetBuilderConfig.swift
//  Parra
//
//  Created by Mick MacCallum on 3/2/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

public class RoadmapWidgetBuilderConfig: LocalComponentBuilderConfig {
    // MARK: - Lifecycle

    public required init() {
        self.title = nil
        self.addRequestButton = nil
        self.requestTitleLabel = nil
        self.requestDescriptionLabel = nil
        self.voteCountLabel = nil
        self.requestUpvoteButton = nil
        self.createdAtLabel = nil
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
        addRequestButtonBuilder: LocalComponentBuilder.ButtonFactory<
            Button<Text>,
            TextButtonConfig,
            TextButtonContent,
            TextButtonAttributes
        >? = nil,
        requestTitleLabelBuilder: LocalComponentBuilder.Factory<
            Text,
            LabelConfig,
            LabelContent,
            LabelAttributes
        >? = nil,
        requestDescriptionLabelBuilder: LocalComponentBuilder.Factory<
            Text,
            LabelConfig,
            LabelContent,
            LabelAttributes
        >? = nil,
        voteCountLabelBuilder: LocalComponentBuilder.Factory<
            Text,
            LabelConfig,
            LabelContent,
            LabelAttributes
        >? = nil,
        requestUpvoteButtonBuilder: LocalComponentBuilder.ButtonFactory<
            Button<Image>,
            ImageButtonConfig,
            ImageButtonContent,
            ImageButtonAttributes
        >? = nil,
        createdAtLabelBuilder: LocalComponentBuilder.Factory<
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
        self.addRequestButton = addRequestButtonBuilder
        self.requestTitleLabel = requestTitleLabelBuilder
        self.requestDescriptionLabel = requestDescriptionLabelBuilder
        self.voteCountLabel = voteCountLabelBuilder
        self.requestUpvoteButton = requestUpvoteButtonBuilder
        self.createdAtLabel = createdAtLabelBuilder
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
    public let addRequestButton: LocalComponentBuilder.ButtonFactory<
        Button<Text>,
        TextButtonConfig,
        TextButtonContent,
        TextButtonAttributes
    >?
    public let requestTitleLabel: LocalComponentBuilder.Factory<
        Text,
        LabelConfig,
        LabelContent,
        LabelAttributes
    >?
    public let requestDescriptionLabel: LocalComponentBuilder.Factory<
        Text,
        LabelConfig,
        LabelContent,
        LabelAttributes
    >?
    public let voteCountLabel: LocalComponentBuilder.Factory<
        Text,
        LabelConfig,
        LabelContent,
        LabelAttributes
    >?
    public let requestUpvoteButton: LocalComponentBuilder.ButtonFactory<
        Button<Image>,
        ImageButtonConfig,
        ImageButtonContent,
        ImageButtonAttributes
    >?
    public let createdAtLabel: LocalComponentBuilder.Factory<
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
