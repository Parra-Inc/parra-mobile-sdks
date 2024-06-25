//
//  CryptoUtilsTests.swift
//  Tests
//
//  Created by Mick MacCallum on 6/25/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

@testable import Parra
import XCTest

final class CryptoUtilsTests: XCTestCase {
    func testEncryptsAndDecrypts() throws {
        let input = "some string that holds some data".data(using: .utf8)!

        let (encrypted, keyString) = try CryptoUtils.encyptData(input)

        XCTAssertNotEqual(input, encrypted)

        let decrypted = try CryptoUtils.decryptData(encrypted, using: keyString)

        XCTAssertEqual(input, decrypted)
    }
}
