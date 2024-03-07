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
        self.statusLabel = nil
        self.createdAtLabel = nil
    }

    public init(
        titleBuilder: LocalComponentBuilder.Factory<
            Text,
            LabelConfig,
            LabelContent,
            LabelAttributes
        >? = nil,
        addRequestButtonBuilder: LocalComponentBuilder.Factory<
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
        requestUpvoteButtonBuilder: LocalComponentBuilder.Factory<
            Button<Image>,
            ImageButtonConfig,
            ImageButtonContent,
            ImageButtonAttributes
        >? = nil,
        statusLabelBuilder: LocalComponentBuilder.Factory<
            Text,
            LabelConfig,
            LabelContent,
            LabelAttributes
        >? = nil,
        createdAtLabelBuilder: LocalComponentBuilder.Factory<
            Text,
            LabelConfig,
            LabelContent,
            LabelAttributes
        >? = nil
    ) {
        self.title = titleBuilder
        self.addRequestButton = addRequestButtonBuilder
        self.requestTitleLabel = requestTitleLabelBuilder
        self.requestDescriptionLabel = requestDescriptionLabelBuilder
        self.voteCountLabel = voteCountLabelBuilder
        self.requestUpvoteButton = requestUpvoteButtonBuilder
        self.statusLabel = statusLabelBuilder
        self.createdAtLabel = createdAtLabelBuilder
    }

    // MARK: - Public

    public let title: LocalComponentBuilder.Factory<
        Text,
        LabelConfig,
        LabelContent,
        LabelAttributes
    >?
    public let addRequestButton: LocalComponentBuilder.Factory<
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
    public let requestUpvoteButton: LocalComponentBuilder.Factory<
        Button<Image>,
        ImageButtonConfig,
        ImageButtonContent,
        ImageButtonAttributes
    >?
    public let statusLabel: LocalComponentBuilder.Factory<
        Text,
        LabelConfig,
        LabelContent,
        LabelAttributes
    >?
    public let createdAtLabel: LocalComponentBuilder.Factory<
        Text,
        LabelConfig,
        LabelContent,
        LabelAttributes
    >?
}
