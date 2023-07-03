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
