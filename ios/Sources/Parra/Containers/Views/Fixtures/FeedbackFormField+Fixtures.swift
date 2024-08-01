//
//  FeedbackFormField+Fixtures.swift
//  Parra
//
//  Created by Mick MacCallum on 2/22/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Foundation

extension FeedbackFormField: ParraFixture {
    static func validStates() -> [FeedbackFormField] {
        return [
            FeedbackFormField(
                name: "type",
                title: "Type of Feedback",
                helperText: "Select one, please!",
                type: .select,
                required: true,
                data: .feedbackFormSelectFieldData(
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
                            )
                        ]
                    )
                )
            ),
            FeedbackFormField(
                name: "response-input",
                title: "Your Feedback",
                helperText: nil,
                type: .input,
                required: true,
                data: .feedbackFormInputFieldData(
                    FeedbackFormInputFieldData(
                        placeholder: "placeholder"
                    )
                )
            ),
            FeedbackFormField(
                name: "response-text",
                title: "Your Feedback",
                helperText: nil,
                type: .text,
                required: true,
                data: .feedbackFormTextFieldData(
                    FeedbackFormTextFieldData(
                        placeholder: "placeholder",
                        lines: 5,
                        minCharacters: 20,
                        maxCharacters: 420,
                        maxHeight: 200
                    )
                )
            )
        ]
    }

    static func invalidStates() -> [FeedbackFormField] {
        return []
    }
}
