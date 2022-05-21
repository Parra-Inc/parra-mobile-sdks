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
    func testCardResponseCoding() throws {
        let cardsResponse = CardsResponse(
            items: [
                ParraCardItem(
                    type: .question,
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
                            type: .choice,
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
                ),
                ParraCardItem(
                    type: .question,
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
                            type: .choice,
                            kind: .checkbox,
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
                            active: false,
                            expiresAt: nil,
                            answerQuota: nil,
                            answer: nil
                        )
                    )
                )
            ]
        )

        let encoded = try JSONEncoder().encode(cardsResponse)
        print(String(data: encoded, encoding: .utf8))
        let decoded = try JSONDecoder().decode(CardsResponse.self, from: encoded)
        
        XCTAssertEqual(cardsResponse, decoded)
    }
}
