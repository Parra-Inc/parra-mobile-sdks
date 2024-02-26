//
//  ParraCardItem+Fixtures.swift
//  Parra
//
//  Created by Mick MacCallum on 2/22/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Foundation

// MARK: - ParraCardItem + ParraFixture

extension ParraCardItem: ParraFixture {
    static func validStates() -> [ParraCardItem] {
        return ParraCardItemFixtures.cardsResponse.items
    }

    static func invalidStates() -> [ParraCardItem] {
        return []
    }
}

enum ParraCardItemFixtures {
    static let choiceCard = ParraCardItem(
        id: "choiceCard",
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
        id: "checkboxCard",
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
        id: "boolCard",
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
        id: "starCard",
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
        id: "imageCard",
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
        id: "ratingCard",
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
        id: "shortTextCard",
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
        id: "shortTextCard",
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
