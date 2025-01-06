//
//  FeedbackFormField+Fixtures.swift
//  Parra
//
//  Created by Mick MacCallum on 2/22/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Foundation

extension ParraFeedbackFormField: ParraFixture {
    public static func validStates() -> [ParraFeedbackFormField] {
        return [
            ParraFeedbackFormField(
                name: "type",
                title: "Type of Feedback",
                helperText: "Select one, please!",
                type: .select,
                required: true,
                hidden: false,
                data: .feedbackFormSelectFieldData(
                    ParraFeedbackFormSelectFieldData(
                        placeholder: "Please select an option",
                        options: [
                            ParraFeedbackFormSelectFieldOption(
                                title: "General feedback",
                                value: "general-feedback",
                                isOther: nil
                            ),
                            ParraFeedbackFormSelectFieldOption(
                                title: "Bug report",
                                value: "bug-report",
                                isOther: nil
                            ),
                            ParraFeedbackFormSelectFieldOption(
                                title: "Feature request",
                                value: "feature-request",
                                isOther: nil
                            ),
                            ParraFeedbackFormSelectFieldOption(
                                title: "Idea",
                                value: "idea",
                                isOther: nil
                            ),
                            ParraFeedbackFormSelectFieldOption(
                                title: "Other",
                                value: "other",
                                isOther: nil
                            )
                        ]
                    )
                )
            ),
            ParraFeedbackFormField(
                name: "response-input",
                title: "Your Feedback",
                helperText: nil,
                type: .input,
                required: true,
                hidden: nil,
                data: .feedbackFormInputFieldData(
                    ParraFeedbackFormInputFieldData(
                        placeholder: "placeholder"
                    )
                )
            ),
            ParraFeedbackFormField(
                name: "response-text",
                title: "Your Feedback",
                helperText: nil,
                type: .text,
                required: true,
                hidden: nil,
                data: .feedbackFormTextFieldData(
                    ParraFeedbackFormTextFieldData(
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

    public static func invalidStates() -> [ParraFeedbackFormField] {
        return []
    }
}
