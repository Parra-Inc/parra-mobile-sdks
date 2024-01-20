//
//  FeedbackFormField+Fixtures.swift
//  Parra
//
//  Created by Mick MacCallum on 1/18/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Foundation

extension FeedbackFormField: ParraFixture {
    static func validStates() -> [FeedbackFormField] {
        return [
            FeedbackFormField(
                name: "text-field",
                title: "We'd love to hear your feedback!",
                helperText: "fill this out",
                type: .text,
                required: true,
                data: .feedbackFormTextFieldData(
                    FeedbackFormTextFieldData(
                        placeholder: "placeholder",
                        lines: 4,
                        maxLines: 69,
                        minCharacters: 20,
                        maxCharacters: 420,
                        maxHeight: 200
                    )
                )
            ),
            FeedbackFormField(
                name: "select-field",
                title: "Which one of these options is the best?",
                helperText: "fill this out, please!",
                type: .select,
                required: true,
                data: .feedbackFormSelectFieldData(
                    FeedbackFormSelectFieldData(
                        placeholder: "Please select an option",
                        options: [
                            .init(title: "General feedback", value: "general", isOther: nil),
                            .init(title: "Bug report", value: "bug", isOther: nil),
                            .init(title: "Feature request", value: "feature", isOther: nil),
                            .init(title: "Idea", value: "idea", isOther: nil),
                            .init(title: "Other", value: "other", isOther: nil),
                        ]
                    )
                )
            )
        ]
    }

    static func invalidStates() -> [FeedbackFormField] {
        return []
    }
}
