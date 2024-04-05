//
//  GeneratedTypes+Swift.swift
//  Tests
//
//  Created by Mick MacCallum on 4/9/22.
//  Copyright © 2022 Parra, Inc. All rights reserved.
//

@testable import Parra
import XCTest

class GeneratedTypesTests: XCTestCase {
    // MARK: - Internal

    func testCodingChoiceCard() throws {
        try assertReencodedWithoutChange(
            object: ParraCardItemFixtures.choiceCard
        )
    }

    func testCodingCheckboxCard() throws {
        try assertReencodedWithoutChange(
            object: ParraCardItemFixtures.checkboxCard
        )
    }

    func testCodingBoolCard() throws {
        try assertReencodedWithoutChange(
            object: ParraCardItemFixtures.boolCard
        )
    }

    func testCodingStarCard() throws {
        try assertReencodedWithoutChange(
            object: ParraCardItemFixtures.starCard
        )
    }

    func testCodingImageCard() throws {
        try assertReencodedWithoutChange(
            object: ParraCardItemFixtures.imageCard
        )
    }

    func testCodingRatingCard() throws {
        try assertReencodedWithoutChange(
            object: ParraCardItemFixtures.ratingCard
        )
    }

    func testCodingShortTextCard() throws {
        try assertReencodedWithoutChange(
            object: ParraCardItemFixtures.shortTextCard
        )
    }

    func testCodingLongTextCard() throws {
        try assertReencodedWithoutChange(
            object: ParraCardItemFixtures.longTextCard
        )
    }

    func testCodingFullCardResponse() throws {
        try assertReencodedWithoutChange(
            object: ParraCardItemFixtures.cardsResponse
        )
    }

    // MARK: - Private

    private func assertReencodedWithoutChange(
        object: some Codable & Equatable
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
