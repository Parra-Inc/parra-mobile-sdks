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
        self.requestTitleLabelDetail = nil
        self.requestDescriptionLabel = nil
        self.requestDescriptionLabelDetail = nil
        self.voteCountLabel = nil
        self.voteCountLabelDetail = nil
        self.requestUpvoteButton = nil
        self.requestUpvoteButtonDetail = nil
        self.statusLabel = nil
        self.statusLabelDetail = nil
        self.createdAtLabel = nil
        self.createdAtLabelDetail = nil
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
        requestTitleLabelDetailBuilder: LocalComponentBuilder.Factory<
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
        requestDescriptionLabelDetailBuilder: LocalComponentBuilder.Factory<
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
        voteCountLabelDetailBuilder: LocalComponentBuilder.Factory<
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
        requestUpvoteButtonDetailBuilder: LocalComponentBuilder.Factory<
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
        statusLabelDetailBuilder: LocalComponentBuilder.Factory<
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
        >? = nil,
        createdAtLabelDetailBuilder: LocalComponentBuilder.Factory<
            Text,
            LabelConfig,
            LabelContent,
            LabelAttributes
        >? = nil
    ) {
        self.title = titleBuilder
        self.addRequestButton = addRequestButtonBuilder
        self.requestTitleLabel = requestTitleLabelBuilder
        self.requestTitleLabelDetail = requestTitleLabelDetailBuilder
        self.requestDescriptionLabel = requestDescriptionLabelBuilder
        self
            .requestDescriptionLabelDetail =
            requestDescriptionLabelDetailBuilder
        self.voteCountLabel = voteCountLabelBuilder
        self.voteCountLabelDetail = voteCountLabelDetailBuilder
        self.requestUpvoteButton = requestUpvoteButtonBuilder
        self.requestUpvoteButtonDetail = requestUpvoteButtonDetailBuilder
        self.statusLabel = statusLabelBuilder
        self.statusLabelDetail = statusLabelDetailBuilder
        self.createdAtLabel = createdAtLabelBuilder
        self.createdAtLabelDetail = createdAtLabelDetailBuilder
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
    public let requestTitleLabelDetail: LocalComponentBuilder.Factory<
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
    public let requestDescriptionLabelDetail: LocalComponentBuilder.Factory<
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
    public let voteCountLabelDetail: LocalComponentBuilder.Factory<
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
    public let requestUpvoteButtonDetail: LocalComponentBuilder.Factory<
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
    public let statusLabelDetail: LocalComponentBuilder.Factory<
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
    public let createdAtLabelDetail: LocalComponentBuilder.Factory<
        Text,
        LabelConfig,
        LabelContent,
        LabelAttributes
    >?
}
