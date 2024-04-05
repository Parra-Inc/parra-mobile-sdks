//
//  RoadmapWidgetConfig.swift
//  Parra
//
//  Created by Mick MacCallum on 3/2/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

public class RoadmapWidgetConfig: ContainerConfig {
    // MARK: - Lifecycle

    required init() {
        self.title = RoadmapWidgetConfig.default.title
        self.tabDescription = RoadmapWidgetConfig.default.tabDescription
        self.addRequestButton = RoadmapWidgetConfig.default.addRequestButton
        self.requestTitles = RoadmapWidgetConfig.default.requestTitles
        self.requestDescriptions = RoadmapWidgetConfig.default
            .requestDescriptions
        self.voteCount = RoadmapWidgetConfig.default.voteCount
        self.requestUpvoteButtons = RoadmapWidgetConfig.default
            .requestUpvoteButtons
        self.createdAt = RoadmapWidgetConfig.default.createdAt
        self.addRequestSuccessToastTitle = RoadmapWidgetConfig.default
            .addRequestSuccessToastTitle
        self.addRequestSuccessToastSubtitle = RoadmapWidgetConfig.default
            .addRequestSuccessToastSubtitle
        self.emptyStateView = RoadmapWidgetConfig.default.emptyStateView
        self.errorStateView = RoadmapWidgetConfig.default.errorStateView
    }

    public init(
        title: LabelConfig,
        tabDescription: LabelConfig,
        addRequestButton: TextButtonConfig,
        requestTitles: LabelConfig,
        requestDescriptions: LabelConfig,
        voteCount: LabelConfig,
        requestUpvoteButtons: ImageButtonConfig,
        createdAt: LabelConfig,
        addRequestSuccessToastTitle: String,
        addRequestSuccessToastSubtitle: String,
        emptyStateView: EmptyStateConfig,
        errorStateView: EmptyStateConfig
    ) {
        self.title = title
        self.tabDescription = tabDescription
        self.addRequestButton = addRequestButton
        self.requestTitles = requestTitles
        self.requestDescriptions = requestDescriptions
        self.voteCount = voteCount
        self.requestUpvoteButtons = requestUpvoteButtons
        self.createdAt = createdAt
        self.addRequestSuccessToastTitle = addRequestSuccessToastTitle
        self.addRequestSuccessToastSubtitle = addRequestSuccessToastSubtitle
        self.emptyStateView = emptyStateView
        self.errorStateView = errorStateView
    }

    // MARK: - Public

    public static let `default` = RoadmapWidgetConfig(
        title: LabelConfig(fontStyle: .title),
        tabDescription: LabelConfig(fontStyle: .subheadline),
        addRequestButton: TextButtonConfig(
            style: .primary,
            size: .large,
            isMaxWidth: true
        ),
        requestTitles: LabelConfig(
            fontStyle: .headline
        ),
        requestDescriptions: LabelConfig(
            fontStyle: .subheadline
        ),
        voteCount: LabelConfig(
            fontStyle: .callout
        ),
        requestUpvoteButtons: ImageButtonConfig(
            style: .primary,
            size: .custom(CGSize(width: 18, height: 18)),
            variant: .plain
        ),
        createdAt: LabelConfig(fontStyle: .caption),
        addRequestSuccessToastTitle: "Request confirmed!",
        addRequestSuccessToastSubtitle: "Thank you for your input! We've noted your suggestion and will consider it for our roadmap after a thorough review.",
        emptyStateView: .default,
        errorStateView: .errorDefault
    )

    public let title: LabelConfig
    public let tabDescription: LabelConfig
    public let addRequestButton: TextButtonConfig
    public let requestTitles: LabelConfig
    public let requestDescriptions: LabelConfig
    public let voteCount: LabelConfig
    public let requestUpvoteButtons: ImageButtonConfig
    public let createdAt: LabelConfig
    public let addRequestSuccessToastTitle: String
    public let addRequestSuccessToastSubtitle: String
    public let emptyStateView: EmptyStateConfig
    public let errorStateView: EmptyStateConfig
}
