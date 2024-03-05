//
//  AppRoadmapConfiguration+Fixtures.swift
//  Parra
//
//  Created by Mick MacCallum on 3/5/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Foundation

extension AppRoadmapConfiguration: ParraFixture {
    static func validStates() -> [AppRoadmapConfiguration] {
        return [
            AppRoadmapConfiguration(
                form: .init(
                    id: UUID().uuidString,
                    createdAt: .now,
                    updatedAt: .now,
                    deletedAt: nil,
                    data: .init(
                        title: "Submit request",
                        description: "We love hearing your suggestions. Let us know about new feature ideas, or if we have any bugs!",
                        fields: FeedbackFormField.validStates()
                    )
                )
            )
        ]
    }

    static func invalidStates() -> [AppRoadmapConfiguration] {
        return []
    }
}
