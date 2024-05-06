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
        self.addRequestSuccessToastTitle = RoadmapWidgetConfig.default
            .addRequestSuccessToastTitle

        self.addRequestSuccessToastSubtitle = RoadmapWidgetConfig.default
            .addRequestSuccessToastSubtitle
    }

    public required init(
        addRequestSuccessToastTitle: String = RoadmapWidgetConfig.default
            .addRequestSuccessToastTitle,
        addRequestSuccessToastSubtitle: String = RoadmapWidgetConfig.default
            .addRequestSuccessToastSubtitle
    ) {
        self.addRequestSuccessToastSubtitle = addRequestSuccessToastSubtitle
        self.addRequestSuccessToastTitle = addRequestSuccessToastTitle
    }

    // MARK: - Public

    public static let `default` = RoadmapWidgetConfig(
        //        addRequestButton: TextButtonConfig(
//            style: .primary,
//            size: .large,
//            isMaxWidth: true
//        ),
//        requestTitles: LabelConfig(
//            fontStyle: .headline
//        ),
//        requestDescriptions: LabelConfig(
//            fontStyle: .subheadline
//        ),
//        voteCount: LabelConfig(
//            fontStyle: .callout
//        ),
        addRequestSuccessToastTitle: "Request confirmed!",
        addRequestSuccessToastSubtitle: "Thank you for your input! We've noted your suggestion and will consider it for our roadmap after a thorough review."
    )

    public let addRequestSuccessToastTitle: String
    public let addRequestSuccessToastSubtitle: String
}
