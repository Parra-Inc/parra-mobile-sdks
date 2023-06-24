//
//  GeneratedTypes+Swift.swift
//  ParraCoreTests
//
//  Created by Mick MacCallum on 4/9/22.
//  Copyright © 2022 Parra, Inc. All rights reserved.
//

import XCTest
@testable import ParraCore

class GeneratedTypesTests: XCTestCase {
    func testCodingChoiceCard() throws {
        try assertReencodedWithoutChange(object: sampleChoiceCard)
    }

    func testCodingCheckboxCard() throws {
        try assertReencodedWithoutChange(object: sampleCheckboxCard)
    }

    func testCodingBoolCard() throws {
        try assertReencodedWithoutChange(object: sampleBoolCard)
    }

    func testCodingStarCard() throws {
        try assertReencodedWithoutChange(object: sampleStarCard)
    }

    func testCodingImageCard() throws {
        try assertReencodedWithoutChange(object: sampleImageCard)
    }

    func testCodingRatingCard() throws {
        try assertReencodedWithoutChange(object: sampleRatingCard)
    }

    func testCodingShortTextCard() throws {
        try assertReencodedWithoutChange(object: sampleShortTextCard)
    }

    func testCodingLongTextCard() throws {
        try assertReencodedWithoutChange(object: sampleLongTextCard)
    }

    func testCodingFullCardResponse() throws {
        try assertReencodedWithoutChange(object: sampleCardsResponse)
    }

    private func assertReencodedWithoutChange<T: Codable & Equatable>(object: T) throws {
        let reencoded = try reencode(object: object)
        XCTAssertEqual(object, reencoded)
    }

    private func reencode<T: Codable>(object: T) throws -> T {
        let encoded = try JSONEncoder().encode(object)
        return try JSONDecoder().decode(T.self, from: encoded)
    }
}

let sampleChoiceCard = ParraCardItem(
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
            createdAt: Date().ISO8601Format(),
            updatedAt: Date().ISO8601Format(),
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
            expiresAt: Date().addingTimeInterval(100000).ISO8601Format(),
            answerQuota: nil,
            answer: nil
        )
    )
)

let sampleCheckboxCard = ParraCardItem(
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
            createdAt: Date().ISO8601Format(),
            updatedAt: Date().ISO8601Format(),
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

let sampleBoolCard = ParraCardItem(
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
            createdAt: Date().ISO8601Format(),
            updatedAt: Date().ISO8601Format(),
            deletedAt: nil,
            tenantId: "24234234",
            title: "Sample question 2",
            subtitle: "this one has a subtitle",
            kind: .boolean,
            data: .booleanQuestionBody(
                BooleanQuestionBody(options: [
                    BooleanQuestionOption(title: "title", value: "value", id: "id"),
                    BooleanQuestionOption(title: "title", value: "value", id: "id"),
                ])
            ),
            active: false,
            expiresAt: nil,
            answerQuota: nil,
            answer: nil
        )
    )
)

let sampleStarCard = ParraCardItem(
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
            createdAt: Date().ISO8601Format(),
            updatedAt: Date().ISO8601Format(),
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

let sampleImageCard = ParraCardItem(
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
            createdAt: Date().ISO8601Format(),
            updatedAt: Date().ISO8601Format(),
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
                            asset: Asset(id: "id", url: URL(string: "parra.io/image.png")!)
                        ),
                        ImageQuestionOption(
                            title: "title2",
                            value: "val2",
                            id: "id2",
                            asset: Asset(id: "id2222", url: URL(string: "parra.io/image2.png")!)
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

let sampleRatingCard = ParraCardItem(
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
            createdAt: Date().ISO8601Format(),
            updatedAt: Date().ISO8601Format(),
            deletedAt: nil,
            tenantId: "24234234",
            title: "Sample question 2",
            subtitle: "this one has a subtitle",
            kind: .rating,
            data: .ratingQuestionBody(
                RatingQuestionBody(
                    options: [
                        RatingQuestionOption(title: "title1", value: 1, id: "1"),
                        RatingQuestionOption(title: "title2", value: 2, id: "2"),
                        RatingQuestionOption(title: "title3", value: 3, id: "3"),
                        RatingQuestionOption(title: "title4", value: 4, id: "4"),
                        RatingQuestionOption(title: "title5", value: 5, id: "5"),
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

let sampleShortTextCard = ParraCardItem(
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
            createdAt: Date().ISO8601Format(),
            updatedAt: Date().ISO8601Format(),
            deletedAt: nil,
            tenantId: "24234234",
            title: "Sample question 2",
            subtitle: "this one has a subtitle",
            kind: .textShort,
            data: .shortTextQuestionBody(
                ShortTextQuestionBody(placeholder: "placeholder", minLength: 50)
            ),
            active: false,
            expiresAt: nil,
            answerQuota: nil,
            answer: nil
        )
    )
)

let sampleLongTextCard = ParraCardItem(
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
            createdAt: Date().ISO8601Format(),
            updatedAt: Date().ISO8601Format(),
            deletedAt: nil,
            tenantId: "24234234",
            title: "Sample question 2",
            subtitle: "this one has a subtitle",
            kind: .textLong,
            data: .longTextQuestionBody(
                LongTextQuestionBody(placeholder: "placeholder", minLength: 1, maxLength: 1000)
            ),
            active: false,
            expiresAt: nil,
            answerQuota: nil,
            answer: nil
        )
    )
)

let sampleCardsResponse = CardsResponse(
    items: [
        sampleChoiceCard,
        sampleCheckboxCard,
        sampleBoolCard,
        sampleStarCard,
        sampleImageCard,
        sampleRatingCard,
        sampleShortTextCard,
        sampleLongTextCard
    ]
)
