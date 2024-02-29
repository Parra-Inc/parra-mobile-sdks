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
        data: .question(choiceQuestion)
    )

    static let choiceQuestion = Question(
        id: "1",
        createdAt: .now,
        updatedAt: .now,
        deletedAt: nil,
        tenantId: "24234234",
        title: "Who would you prefer to see in concert?",
        subtitle: "All these artists are performing on the same night. You can only pick 1!",
        kind: .radio,
        data: .choiceQuestionBody(choiceQuestionData),
        active: true,
        expiresAt: Date().addingTimeInterval(100_000)
            .ISO8601Format(),
        answerQuota: nil,
        answer: nil
    )

    static let choiceQuestionData = ChoiceQuestionBody(
        options: [
            ChoiceQuestionOption(
                title: "Taylor Swift",
                value: "",
                isOther: nil,
                id: "taytay"
            ),
            ChoiceQuestionOption(
                title: "Green Day",
                value: "",
                isOther: nil,
                id: "green-day"
            ),

            ChoiceQuestionOption(
                title: "Post Malone",
                value: "",
                isOther: nil,
                id: "post-malone"
            )
        ]
    )

    static let checkboxCard = ParraCardItem(
        id: "checkboxCard",
        campaignId: "",
        campaignActionId: "",
        questionId: "qid",
        type: .question,
        displayType: .inline,
        version: "1",
        data: .question(checkboxQuestion)
    )

    static let checkboxQuestion = Question(
        id: "2",
        createdAt: .now,
        updatedAt: .now,
        deletedAt: nil,
        tenantId: "24234234",
        title: "Which ice cream flavors are your favorites?",
        subtitle: "The Parra team is partial to strawberry!",
        kind: .checkbox,
        data: .checkboxQuestionBody(checkboxQuestionData),
        active: false,
        expiresAt: nil,
        answerQuota: nil,
        answer: nil
    )

    static let checkboxQuestionData = CheckboxQuestionBody(
        options: [
            CheckboxQuestionOption(
                title: "Chocolate",
                value: "",
                isOther: nil,
                id: "op1"
            ),
            CheckboxQuestionOption(
                title: "Vanilla",
                value: "",
                isOther: nil,
                id: "op2"
            ),
            CheckboxQuestionOption(
                title: "Strawberry",
                value: "",
                isOther: nil,
                id: "op2"
            )
        ]
    )

    static let boolCard = ParraCardItem(
        id: "boolCard",
        campaignId: "",
        campaignActionId: "",
        questionId: "qid",
        type: .question,
        displayType: .popup,
        version: "1",
        data: .question(boolQuestion)
    )

    static let boolQuestion = Question(
        id: "3",
        createdAt: .now,
        updatedAt: .now,
        deletedAt: nil,
        tenantId: "24234234",
        title: "Are you satisfied with Parra?",
        subtitle: "We value your opinion and are always looking to improve.",
        kind: .boolean,
        data: .booleanQuestionBody(boolQuestionData),
        active: false,
        expiresAt: nil,
        answerQuota: nil,
        answer: nil
    )

    static let boolQuestionData = BooleanQuestionBody(
        options: [
            BooleanQuestionOption(
                title: "Yes",
                value: "yes",
                id: "id1"
            ),
            BooleanQuestionOption(
                title: "No",
                value: "no",
                id: "id2"
            )
        ]
    )

    static let starCard = ParraCardItem(
        id: "starCard",
        campaignId: "",
        campaignActionId: "",
        questionId: "qid",
        type: .question,
        displayType: .inline,
        version: "1",
        data: .question(starQuestion)
    )

    static let starQuestion = Question(
        id: "4",
        createdAt: .now,
        updatedAt: .now,
        deletedAt: nil,
        tenantId: "24234234",
        title: "Rate your experience",
        subtitle: "Let us know how we're doing by providing a rating.",
        kind: .star,
        data: .starQuestionBody(starQuestionData),
        active: false,
        expiresAt: nil,
        answerQuota: nil,
        answer: nil
    )

    static let starQuestionData = StarQuestionBody(
        starCount: 5,
        leadingLabel: "leading",
        centerLabel: "center",
        trailingLabel: "trailing"
    )

    static let imageCard = ParraCardItem(
        id: "imageCard",
        campaignId: "",
        campaignActionId: "",
        questionId: "qid",
        type: .question,
        displayType: .drawer,
        version: "1",
        data: .question(imageQuestion)
    )

    static let imageQuestion = Question(
        id: "5",
        createdAt: .now,
        updatedAt: .now,
        deletedAt: nil,
        tenantId: "24234234",
        title: "Sample image question",
        subtitle: "A choice but with images",
        kind: .image,
        data: .imageQuestionBody(imageQuestionData),
        active: false,
        expiresAt: nil,
        answerQuota: nil,
        answer: nil
    )

    static let imageQuestionData = ImageQuestionBody(
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

    static let ratingCard = ParraCardItem(
        id: "ratingCard",
        campaignId: "",
        campaignActionId: "",
        questionId: "qid",
        type: .question,
        displayType: .popup,
        version: "1",
        data: .question(ratingQuestion)
    )

    static let ratingQuestion = Question(
        id: "6",
        createdAt: .now,
        updatedAt: .now,
        deletedAt: nil,
        tenantId: "24234234",
        title: "Sample rating question",
        subtitle: "Pick a number!",
        kind: .rating,
        data: .ratingQuestionBody(ratingQuestionData),
        active: false,
        expiresAt: nil,
        answerQuota: nil,
        answer: nil
    )

    static let ratingQuestionData = RatingQuestionBody(
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

    static let shortTextCard = ParraCardItem(
        id: "shortTextCard",
        campaignId: "",
        campaignActionId: "",
        questionId: "qid",
        type: .question,
        displayType: .inline,
        version: "1",
        data: .question(shortTextQuestion)
    )

    static let shortTextQuestion = Question(
        id: "7",
        createdAt: .now,
        updatedAt: .now,
        deletedAt: nil,
        tenantId: "24234234",
        title: "Sample short text question",
        subtitle: "Single line text input",
        kind: .textShort,
        data: .shortTextQuestionBody(shortTextQuestionData),
        active: false,
        expiresAt: nil,
        answerQuota: nil,
        answer: nil
    )

    static let shortTextQuestionData = ShortTextQuestionBody(
        placeholder: "placeholder",
        minLength: 50
    )

    static let longTextCard = ParraCardItem(
        id: "shortTextCard",
        campaignId: "",
        campaignActionId: "",
        questionId: "qid",
        type: .question,
        displayType: .popup,
        version: "1",
        data: .question(longTextQuestion)
    )

    static let longTextQuestion = Question(
        id: "7",
        createdAt: .now,
        updatedAt: .now,
        deletedAt: nil,
        tenantId: "24234234",
        title: "Sample long text question",
        subtitle: "Multi line extended response text input",
        kind: .textLong,
        data: .longTextQuestionBody(longTextQuestionData),
        active: false,
        expiresAt: nil,
        answerQuota: nil,
        answer: nil
    )

    static let longTextQuestionData = LongTextQuestionBody(
        placeholder: "placeholder",
        minLength: 1,
        maxLength: 1_000
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
