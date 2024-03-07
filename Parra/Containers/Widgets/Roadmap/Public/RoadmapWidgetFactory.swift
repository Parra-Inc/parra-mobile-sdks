//
//  RoadmapWidgetFactory.swift
//  Parra
//
//  Created by Mick MacCallum on 3/2/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

public struct RoadmapWidgetFactory: ParraComponentFactory {
    // MARK: - Lifecycle

    public init(
        titleBuilder: ComponentBuilder.Factory<
            Text,
            LabelConfig,
            LabelContent,
            LabelAttributes
        >? = nil,
        addRequestButtonBuilder: ComponentBuilder.Factory<
            Button<Text>,
            TextButtonConfig,
            TextButtonContent,
            TextButtonAttributes
        >? = nil,
        requestTitleLabelBuilder: ComponentBuilder.Factory<
            Text,
            LabelConfig,
            LabelContent,
            LabelAttributes
        >? = nil,
        requestDescriptionLabelBuilder: ComponentBuilder.Factory<
            Text,
            LabelConfig,
            LabelContent,
            LabelAttributes
        >? = nil,
        voteCountLabelBuilder: ComponentBuilder.Factory<
            Text,
            LabelConfig,
            LabelContent,
            LabelAttributes
        >? = nil,
        requestUpvoteButtonBuilder: ComponentBuilder.Factory<
            Button<Text>,
            ImageButtonConfig,
            ImageButtonContent,
            ImageButtonAttributes
        >? = nil,
        statusLabelBuilder: ComponentBuilder.Factory<
            Text,
            LabelConfig,
            LabelContent,
            LabelAttributes
        >? = nil,
        createdAtLabelBuilder: ComponentBuilder.Factory<
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

    public let title: ComponentBuilder.Factory<
        Text,
        LabelConfig,
        LabelContent,
        LabelAttributes
    >?
    public let addRequestButton: ComponentBuilder.Factory<
        Button<Text>,
        TextButtonConfig,
        TextButtonContent,
        TextButtonAttributes
    >?
    public let requestTitleLabel: ComponentBuilder.Factory<
        Text,
        LabelConfig,
        LabelContent,
        LabelAttributes
    >?
    public let requestDescriptionLabel: ComponentBuilder.Factory<
        Text,
        LabelConfig,
        LabelContent,
        LabelAttributes
    >?
    public let voteCountLabel: ComponentBuilder.Factory<
        Text,
        LabelConfig,
        LabelContent,
        LabelAttributes
    >?
    public let requestUpvoteButton: ComponentBuilder.Factory<
        Button<Text>,
        ImageButtonConfig,
        ImageButtonContent,
        ImageButtonAttributes
    >?
    public let statusLabel: ComponentBuilder.Factory<
        Text,
        LabelConfig,
        LabelContent,
        LabelAttributes
    >?
    public let createdAtLabel: ComponentBuilder.Factory<
        Text,
        LabelConfig,
        LabelContent,
        LabelAttributes
    >?
}
