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
        requestDescriptions: LabelConfig,
        voteCount: LabelConfig,
        requestUpvoteButtons: ImageButtonConfig,
        status: LabelConfig,
        createdAt: LabelConfig
    ) {
        self.title = title
        self.addRequestButton = addRequestButton
        self.requestTitles = requestTitles
        self.requestDescriptions = requestDescriptions
        self.voteCount = voteCount
        self.requestUpvoteButtons = requestUpvoteButtons
        self.status = status
        self.createdAt = createdAt
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
        status: LabelConfig(fontStyle: .caption2),
        createdAt: LabelConfig(fontStyle: .caption)
    )

    public let title: LabelConfig
    public let addRequestButton: TextButtonConfig
    public let requestTitles: LabelConfig
    public let requestDescriptions: LabelConfig
    public let voteCount: LabelConfig
    public let requestUpvoteButtons: ImageButtonConfig
    public let status: LabelConfig
    public let createdAt: LabelConfig
}
