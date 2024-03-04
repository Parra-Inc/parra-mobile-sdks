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
        addRequestButton: ButtonConfig,
        requestTitles: LabelConfig,
        requestDescriptions: LabelConfig,
        voteCount: LabelConfig,
        requestUpvoteButtons: ButtonConfig
    ) {
        self.title = title
        self.addRequestButton = addRequestButton
        self.requestTitles = requestTitles
        self.requestDescriptions = requestDescriptions
        self.voteCount = voteCount
        self.requestUpvoteButtons = requestUpvoteButtons
    }

    // MARK: - Public

    public static let `default` = RoadmapWidgetConfig(
        title: LabelConfig(fontStyle: .title),
        addRequestButton: ButtonConfig(
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
        requestUpvoteButtons: ButtonConfig(
            style: .primary,
            size: .small,
            isMaxWidth: false
        )
    )

    public let title: LabelConfig
    public let addRequestButton: ButtonConfig
    public let requestTitles: LabelConfig
    public let requestDescriptions: LabelConfig
    public let voteCount: LabelConfig
    public let requestUpvoteButtons: ButtonConfig
}