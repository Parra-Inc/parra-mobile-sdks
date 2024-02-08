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
    // MARK: - Cards

    enum Cards {
        static let choiceCard = ParraCardItem(
            id: "id",
            campaignId: "",
            campaignActionId: "",
            questionId: "qid",
            type: .question,
            displayType: .drawer,
            version: "1",
            data: .question(
                Question(
                    id: "1",
                    createdAt: .now,
                    updatedAt: .now,
                    deletedAt: nil,
                    tenantId: "24234234",
                    title: "Sample question 1",
                    subtitle: nil,
                    kind: .radio,
                    data: .choiceQuestionBody(
                        ChoiceQuestionBody(
                            options: [
                                ChoiceQuestionOption(
                                    title: "option 1",
                                    value: "",
                                    isOther: nil,
                                    id: "op1"
                                ),
                                ChoiceQuestionOption(
                                    title: "option 2",
                                    value: "",
                                    isOther: nil,
                                    id: "op2"
                                )
                            ]
                        )
                    ),
                    active: true,
                    expiresAt: Date().addingTimeInterval(100_000)
                        .ISO8601Format(),
                    answerQuota: nil,
                    answer: nil
                )
            )
        )

        static let checkboxCard = ParraCardItem(
            id: "id",
            campaignId: "",
            campaignActionId: "",
            questionId: "qid",
            type: .question,
            displayType: .inline,
            version: "1",
            data: .question(
                Question(
                    id: "2",
                    createdAt: .now,
                    updatedAt: .now,
                    deletedAt: nil,
                    tenantId: "24234234",
                    title: "Sample question 2",
                    subtitle: "this one has a subtitle",
                    kind: .checkbox,
                    data: .checkboxQuestionBody(
                        CheckboxQuestionBody(
                            options: [
                                CheckboxQuestionOption(
                                    title: "option 1",
                                    value: "",
                                    isOther: nil,
                                    id: "op1"
                                ),
                                CheckboxQuestionOption(
                                    title: "option 2",
                                    value: "",
                                    isOther: nil,
                                    id: "op2"
                                )
                            ]
                        )
                    ),
                    active: false,
                    expiresAt: nil,
                    answerQuota: nil,
                    answer: nil
                )
            )
        )

        static let boolCard = ParraCardItem(
            id: "id",
            campaignId: "",
            campaignActionId: "",
            questionId: "qid",
            type: .question,
            displayType: .popup,
            version: "1",
            data: .question(
                Question(
                    id: "3",
                    createdAt: .now,
                    updatedAt: .now,
                    deletedAt: nil,
                    tenantId: "24234234",
                    title: "Sample question 2",
                    subtitle: "this one has a subtitle",
                    kind: .boolean,
                    data: .booleanQuestionBody(
                        BooleanQuestionBody(options: [
                            BooleanQuestionOption(
                                title: "title",
                                value: "value",
                                id: "id"
                            ),
                            BooleanQuestionOption(
                                title: "title",
                                value: "value",
                                id: "id"
                            )
                        ])
                    ),
                    active: false,
                    expiresAt: nil,
                    answerQuota: nil,
                    answer: nil
                )
            )
        )

        static let starCard = ParraCardItem(
            id: "id",
            campaignId: "",
            campaignActionId: "",
            questionId: "qid",
            type: .question,
            displayType: .inline,
            version: "1",
            data: .question(
                Question(
                    id: "4",
                    createdAt: .now,
                    updatedAt: .now,
                    deletedAt: nil,
                    tenantId: "24234234",
                    title: "Sample question 2",
                    subtitle: "this one has a subtitle",
                    kind: .star,
                    data: .starQuestionBody(
                        StarQuestionBody(
                            starCount: 5,
                            leadingLabel: "leading",
                            centerLabel: "center",
                            trailingLabel: "trailing"
                        )
                    ),
                    active: false,
                    expiresAt: nil,
                    answerQuota: nil,
                    answer: nil
                )
            )
        )

        static let imageCard = ParraCardItem(
            id: "id",
            campaignId: "",
            campaignActionId: "",
            questionId: "qid",
            type: .question,
            displayType: .drawer,
            version: "1",
            data: .question(
                Question(
                    id: "5",
                    createdAt: .now,
                    updatedAt: .now,
                    deletedAt: nil,
                    tenantId: "24234234",
                    title: "Sample question 2",
                    subtitle: "this one has a subtitle",
                    kind: .image,
                    data: .imageQuestionBody(
                        ImageQuestionBody(
                            options: [
                                ImageQuestionOption(
                                    title: "title",
                                    value: "val",
                                    id: "id",
                                    asset: Asset(
                                        id: "id",
                                        url: URL(string: "parra.io/image.png")!
                                    )
                                ),
                                ImageQuestionOption(
                                    title: "title2",
                                    value: "val2",
                                    id: "id2",
                                    asset: Asset(
                                        id: "id2222",
                                        url: URL(string: "parra.io/image2.png")!
                                    )
                                )
                            ]
                        )
                    ),
                    active: false,
                    expiresAt: nil,
                    answerQuota: nil,
                    answer: nil
                )
            )
        )

        static let ratingCard = ParraCardItem(
            id: "id",
            campaignId: "",
            campaignActionId: "",
            questionId: "qid",
            type: .question,
            displayType: .popup,
            version: "1",
            data: .question(
                Question(
                    id: "6",
                    createdAt: .now,
                    updatedAt: .now,
                    deletedAt: nil,
                    tenantId: "24234234",
                    title: "Sample question 2",
                    subtitle: "this one has a subtitle",
                    kind: .rating,
                    data: .ratingQuestionBody(
                        RatingQuestionBody(
                            options: [
                                RatingQuestionOption(
                                    title: "title1",
                                    value: 1,
                                    id: "1"
                                ),
                                RatingQuestionOption(
                                    title: "title2",
                                    value: 2,
                                    id: "2"
                                ),
                                RatingQuestionOption(
                                    title: "title3",
                                    value: 3,
                                    id: "3"
                                ),
                                RatingQuestionOption(
                                    title: "title4",
                                    value: 4,
                                    id: "4"
                                ),
                                RatingQuestionOption(
                                    title: "title5",
                                    value: 5,
                                    id: "5"
                                )
                            ],
                            leadingLabel: "leading",
                            centerLabel: "center",
                            trailingLabel: "trailing"
                        )
                    ),
                    active: false,
                    expiresAt: nil,
                    answerQuota: nil,
                    answer: nil
                )
            )
        )

        static let shortTextCard = ParraCardItem(
            id: "id",
            campaignId: "",
            campaignActionId: "",
            questionId: "qid",
            type: .question,
            displayType: .inline,
            version: "1",
            data: .question(
                Question(
                    id: "7",
                    createdAt: .now,
                    updatedAt: .now,
                    deletedAt: nil,
                    tenantId: "24234234",
                    title: "Sample question 2",
                    subtitle: "this one has a subtitle",
                    kind: .textShort,
                    data: .shortTextQuestionBody(
                        ShortTextQuestionBody(
                            placeholder: "placeholder",
                            minLength: 50
                        )
                    ),
                    active: false,
                    expiresAt: nil,
                    answerQuota: nil,
                    answer: nil
                )
            )
        )

        static let longTextCard = ParraCardItem(
            id: "id",
            campaignId: "",
            campaignActionId: "",
            questionId: "qid",
            type: .question,
            displayType: .popup,
            version: "1",
            data: .question(
                Question(
                    id: "7",
                    createdAt: .now,
                    updatedAt: .now,
                    deletedAt: nil,
                    tenantId: "24234234",
                    title: "Sample question 2",
                    subtitle: "this one has a subtitle",
                    kind: .textLong,
                    data: .longTextQuestionBody(
                        LongTextQuestionBody(
                            placeholder: "placeholder",
                            minLength: 1,
                            maxLength: 1_000
                        )
                    ),
                    active: false,
                    expiresAt: nil,
                    answerQuota: nil,
                    answer: nil
                )
            )
        )

        static let cardsResponse = CardsResponse(
            items: [
                choiceCard,
                checkboxCard,
                boolCard,
                starCard,
                imageCard,
                ratingCard,
                shortTextCard,
                longTextCard
            ]
        )
    }

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
                                    maxLines: 69,
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
