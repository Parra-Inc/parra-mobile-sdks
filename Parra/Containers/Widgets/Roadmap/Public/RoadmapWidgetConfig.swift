//
//  RoadmapWidgetConfig.swift
//  Parra
//
//  Created by Mick MacCallum on 3/2/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

public class RoadmapWidgetConfig: ContainerConfig, Observable {
    // MARK: - Lifecycle

    init(
        title: LabelConfig,
        addRequestButton: TextButtonConfig,
        requestTitles: LabelConfig,
        requestTitlesDetail: LabelConfig,
        requestDescriptions: LabelConfig,
        requestDescriptionsDetail: LabelConfig,
        voteCount: LabelConfig,
        voteCountDetail: LabelConfig,
        requestUpvoteButtons: ImageButtonConfig,
        requestUpvoteButtonsDetail: ImageButtonConfig,
        status: LabelConfig,
        statusDetail: LabelConfig,
        createdAt: LabelConfig,
        createdAtDetail: LabelConfig,
        addRequestSuccessToastTitle: String,
        addRequestSuccessToastSubtitle: String
    ) {
        self.title = title
        self.addRequestButton = addRequestButton
        self.requestTitles = requestTitles
        self.requestTitlesDetail = requestTitlesDetail
        self.requestDescriptions = requestDescriptions
        self.requestDescriptionsDetail = requestDescriptionsDetail
        self.voteCount = voteCount
        self.voteCountDetail = voteCountDetail
        self.requestUpvoteButtons = requestUpvoteButtons
        self.requestUpvoteButtonsDetail = requestUpvoteButtonsDetail
        self.status = status
        self.statusDetail = statusDetail
        self.createdAt = createdAt
        self.createdAtDetail = createdAtDetail
        self.addRequestSuccessToastTitle = addRequestSuccessToastTitle
        self.addRequestSuccessToastSubtitle = addRequestSuccessToastSubtitle
    }

    // MARK: - Public

    public static let `default` = RoadmapWidgetConfig(
        title: LabelConfig(fontStyle: .title),
        addRequestButton: TextButtonConfig(
            style: .primary,
            size: .large,
            isMaxWidth: true
        ),
        requestTitles: LabelConfig(
            fontStyle: .headline
        ),
        requestTitlesDetail: LabelConfig(
            fontStyle: .headline
        ),
        requestDescriptions: LabelConfig(
            fontStyle: .subheadline
        ),
        requestDescriptionsDetail: LabelConfig(
            fontStyle: .subheadline
        ),
        voteCount: LabelConfig(
            fontStyle: .callout
        ),
        voteCountDetail: LabelConfig(
            fontStyle: .callout
        ),
        requestUpvoteButtons: ImageButtonConfig(
            style: .primary,
            size: .custom(CGSize(width: 18, height: 18)),
            variant: .plain
        ),
        requestUpvoteButtonsDetail: ImageButtonConfig(
            style: .primary,
            size: .custom(CGSize(width: 18, height: 18)),
            variant: .plain
        ),
        status: LabelConfig(fontStyle: .caption2),
        statusDetail: LabelConfig(fontStyle: .caption2),
        createdAt: LabelConfig(fontStyle: .caption),
        createdAtDetail: LabelConfig(fontStyle: .caption),
        addRequestSuccessToastTitle: "Request confirmed!",
        addRequestSuccessToastSubtitle: "Thank you for your input! We've noted your suggestion and will consider it for our roadmap after a thorough review."
    )

    public let title: LabelConfig
    public let addRequestButton: TextButtonConfig
    public let requestTitles: LabelConfig
    public let requestTitlesDetail: LabelConfig
    public let requestDescriptions: LabelConfig
    public let requestDescriptionsDetail: LabelConfig
    public let voteCount: LabelConfig
    public let voteCountDetail: LabelConfig
    public let requestUpvoteButtons: ImageButtonConfig
    public let requestUpvoteButtonsDetail: ImageButtonConfig
    public let status: LabelConfig
    public let statusDetail: LabelConfig
    public let createdAt: LabelConfig
    public let createdAtDetail: LabelConfig
    public let addRequestSuccessToastTitle: String
    public let addRequestSuccessToastSubtitle: String
}
