//
//  TestData.swift
//  ParraTests
//
//  Created by Mick MacCallum on 7/3/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation
@testable import Parra

enum TestData {
    // MARK: - Forms

    enum Forms {
        static func formResponse(
            formId: String = UUID().uuidString
        ) -> ParraFeedbackFormResponse {
            return ParraFeedbackFormResponse(
                id: formId,
                createdAt: .now,
                updatedAt: .now,
                deletedAt: nil,
                data: FeedbackFormData(
                    title: "Feedback form",
                    description: "some description",
                    fields: [
                        FeedbackFormField(
                            name: "field 1",
                            title: "Field 1",
                            helperText: "fill this out",
                            type: .text,
                            required: true,
                            data: .feedbackFormTextFieldData(
                                FeedbackFormTextFieldData(
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
        }
    }

    // MARK: - Sessions

    enum Sessions {
        static let successResponse = ParraSessionsResponse(
            shouldPoll: false,
            retryDelay: 0,
            retryTimes: 0
        )

        static let pollResponse = ParraSessionsResponse(
            shouldPoll: true,
            retryDelay: 15,
            retryTimes: 5
        )
    }

    // MARK: - Auth

    enum Auth {
        static let successResponse = ParraCredential(
            token: UUID().uuidString
        )
    }
}
