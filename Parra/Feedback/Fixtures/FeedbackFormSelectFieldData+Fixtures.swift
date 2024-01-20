//
//  FeedbackFormSelectFieldData+Fixtures.swift
//  Parra
//
//  Created by Mick MacCallum on 1/18/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Foundation

extension FeedbackFormSelectFieldData: ParraFixture {    
    static func validStates() -> [FeedbackFormSelectFieldData] {
        return [
            FeedbackFormSelectFieldData(
                placeholder: "Please select an option",
                options: [
                    FeedbackFormSelectFieldOption(
                        title: "General feedback",
                        value: "general-feedback",
                        isOther: nil
                    ),
                    FeedbackFormSelectFieldOption(
                        title: "Bug report",
                        value: "bug-report",
                        isOther: nil
                    ),
                    FeedbackFormSelectFieldOption(
                        title: "Feature request",
                        value: "feature-request",
                        isOther: nil
                    ),
                    FeedbackFormSelectFieldOption(
                        title: "Idea",
                        value: "idea",
                        isOther: nil
                    ),
                    FeedbackFormSelectFieldOption(
                        title: "Other",
                        value: "other",
                        isOther: nil
                    ),
                ]
            )
        ]
    }

    static func invalidStates() -> [FeedbackFormSelectFieldData] {
        return []
    }
}
