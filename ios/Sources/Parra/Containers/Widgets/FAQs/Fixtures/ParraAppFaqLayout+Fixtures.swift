//
//  ParraAppFaqLayout+Fixtures.swift
//  Parra
//
//  Created by Mick MacCallum on 12/3/24.
//

import Foundation

extension ParraAppFaqLayout: ParraFixture {
    public static func validStates() -> [ParraAppFaqLayout] {
        return [
            ParraAppFaqLayout(
                id: .uuid,
                createdAt: .now,
                updatedAt: .now,
                deletedAt: nil,
                tenantId: .uuid,
                title: "FAQs",
                description: "Some of our most frequently asked questions",
                appAreaId: nil,
                sections: [
                    ParraAppFaqSection(
                        id: .uuid,
                        createdAt: .now,
                        updatedAt: .now,
                        deletedAt: nil,
                        title: "The Parra Platform",
                        description: "Learn more about the Parra Platform",
                        items: [
                            ParraAppFaq(
                                id: .uuid,
                                createdAt: .now,
                                updatedAt: .now,
                                deletedAt: nil,
                                title: "Is Parra the best?",
                                body: "We think so! We have been building and testing Parra for over a year and have found it to be a great platform for building apps."
                            ),
                            ParraAppFaq(
                                id: .uuid,
                                createdAt: .now,
                                updatedAt: .now,
                                deletedAt: nil,
                                title: "Is Parra free?",
                                body: "Parra is free to use. You can build apps for free and try out the platform for yourself. We also offer a free trial of Parra Pro, which includes unlimited apps and access to all features."
                            )
                        ]
                    )
                ],
                feedbackForm: ParraFeedbackFormDataStub(
                    id: .uuid,
                    createdAt: .now,
                    updatedAt: .now,
                    deletedAt: nil,
                    data: ParraFeedbackFormData(
                        title: "Ask a question",
                        description: "We'll get back to you as soon as possible.",
                        fields: [
                            ParraFeedbackFormField(
                                name: "question",
                                title: "Question",
                                helperText: nil,
                                type: .text,
                                required: true,
                                data: .feedbackFormTextFieldData(
                                    ParraFeedbackFormTextFieldData(
                                        placeholder: nil,
                                        lines: nil,
                                        minCharacters: nil,
                                        maxCharacters: nil,
                                        maxHeight: nil
                                    )
                                )
                            )
                        ]
                    )
                )
            )
        ]
    }

    public static func invalidStates() -> [ParraAppFaqLayout] {
        return []
    }
}
