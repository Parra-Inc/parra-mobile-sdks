//
//  ParraFeedbackForm+Fixtures.swift
//  Parra
//
//  Created by Mick MacCallum on 4/5/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Foundation

extension ParraFeedbackForm: ParraFixture {
    public static func validStates() -> [ParraFeedbackForm] {
        return [
            .testForm(with: UUID().uuidString)
        ]
    }

    public static func invalidStates() -> [ParraFeedbackForm] {
        return []
    }

    static func testForm(
        with formId: String
    ) -> ParraFeedbackForm {
        return ParraFeedbackForm(
            from: ParraFeedbackFormResponse(
                id: formId,
                createdAt: .now,
                updatedAt: .now,
                deletedAt: nil,
                data: ParraFeedbackFormData(
                    title: "Feedback form",
                    description: "some description",
                    fields: [
                        ParraFeedbackFormField(
                            name: "field 1",
                            title: "Field 1",
                            helperText: "fill this out",
                            type: .text,
                            required: true,
                            hidden: false,
                            data: .feedbackFormTextFieldData(
                                ParraFeedbackFormTextFieldData(
                                    placeholder: "placeholder",
                                    lines: 4,
                                    minCharacters: 20,
                                    maxCharacters: 420,
                                    maxHeight: 200
                                )
                            )
                        )
                    ]
                )
            )
        )
    }
}
