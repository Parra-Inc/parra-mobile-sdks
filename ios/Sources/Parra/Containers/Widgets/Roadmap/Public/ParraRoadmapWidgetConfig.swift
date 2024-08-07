//
//  RoadmapWidgetConfig.swift
//  Parra
//
//  Created by Mick MacCallum on 3/2/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

public class ParraRoadmapWidgetConfig: ContainerConfig {
    // MARK: - Lifecycle

    required init() {
        self.addRequestSuccessToastTitle = ParraRoadmapWidgetConfig.default
            .addRequestSuccessToastTitle

        self.addRequestSuccessToastSubtitle = ParraRoadmapWidgetConfig.default
            .addRequestSuccessToastSubtitle
    }

    public required init(
        addRequestSuccessToastTitle: String = ParraRoadmapWidgetConfig.default
            .addRequestSuccessToastTitle,
        addRequestSuccessToastSubtitle: String = ParraRoadmapWidgetConfig.default
            .addRequestSuccessToastSubtitle
    ) {
        self.addRequestSuccessToastSubtitle = addRequestSuccessToastSubtitle
        self.addRequestSuccessToastTitle = addRequestSuccessToastTitle
    }

    // MARK: - Public

    public static let `default` = ParraRoadmapWidgetConfig(
        addRequestSuccessToastTitle: "Request confirmed!",
        addRequestSuccessToastSubtitle: "Thank you for your input! We've noted your suggestion and will consider it for our roadmap after a thorough review."
    )

    public let addRequestSuccessToastTitle: String
    public let addRequestSuccessToastSubtitle: String
}
