//
//  GeneratedTypes+Swift.swift
//  ParraTests
//
//  Created by Mick MacCallum on 4/9/22.
//  Copyright © 2022 Parra, Inc. All rights reserved.
//

import XCTest
@testable import Parra

class GeneratedTypesTests: XCTestCase {
    func testCodingChoiceCard() throws {
        try assertReencodedWithoutChange(
            object: TestData.Cards.choiceCard
        )
    }

    func testCodingCheckboxCard() throws {
        try assertReencodedWithoutChange(
            object: TestData.Cards.checkboxCard
        )
    }

    func testCodingBoolCard() throws {
        try assertReencodedWithoutChange(
            object: TestData.Cards.boolCard
        )
    }

    func testCodingStarCard() throws {
        try assertReencodedWithoutChange(
            object: TestData.Cards.starCard
        )
    }

    func testCodingImageCard() throws {
        try assertReencodedWithoutChange(
            object: TestData.Cards.imageCard
        )
    }

    func testCodingRatingCard() throws {
        try assertReencodedWithoutChange(
            object: TestData.Cards.ratingCard
        )
    }

    func testCodingShortTextCard() throws {
        try assertReencodedWithoutChange(
            object: TestData.Cards.shortTextCard
        )
    }

    func testCodingLongTextCard() throws {
        try assertReencodedWithoutChange(
            object: TestData.Cards.longTextCard
        )
    }

    func testCodingFullCardResponse() throws {
        try assertReencodedWithoutChange(
            object: TestData.Cards.cardsResponse
        )
    }

    private func assertReencodedWithoutChange<T: Codable & Equatable>(
        object: T
    ) throws {
        let reencoded = try reencode(object: object)

        XCTAssertEqual(object, reencoded)
    }

    private func reencode<T: Codable>(
            object: T
    ) throws -> T {
        let encoded = try JSONEncoder().encode(object)

        return try JSONDecoder().decode(T.self, from: encoded)
    }
}
