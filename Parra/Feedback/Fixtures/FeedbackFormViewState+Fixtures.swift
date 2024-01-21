//
//  FeedbackFormViewState+Fixtures.swift
//  Parra
//
//  Created by Mick MacCallum on 1/20/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Foundation

extension FeedbackFormViewState: ParraFixture {
    static func validStates() -> [FeedbackFormViewState] {

        return [
            FeedbackFormViewState(
                formData: FeedbackFormData(
                    title: "Leave feedback",
                    description: "We'd love to hear from you. Your input helps us make our product better.",
                    fields: [
                        .init(
                            name: "type",
                            title: "Type of Feedback",
                            helperText: nil,
                            type: .select,
                            required: true,
                            data: .feedbackFormSelectFieldData(
                                FeedbackFormSelectFieldData.validStates()[0]
                            )
                        ),
                        .init(
                            name: "response",
                            title: "Your Feedback",
                            helperText: nil,
                            type: .text,
                            required: true,
                            data: .feedbackFormTextFieldData(
                                FeedbackFormTextFieldData.validStates()[0]
                            )
                        )
                    ]
                )
            )
        ]
    }

    static func invalidStates() -> [FeedbackFormViewState] {
        return []
    }
}
