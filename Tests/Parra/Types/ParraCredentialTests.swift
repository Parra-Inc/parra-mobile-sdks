//
//  ParraCredentialTests.swift
//  Tests
//
//  Created by Mick MacCallum on 8/28/22.
//  Copyright © 2022 Parra, Inc. All rights reserved.
//

@testable import Parra
import XCTest

final class ParraCredentialTests: XCTestCase {
    func testDecodesFromToken() throws {
        let _ = try JSONDecoder().decode(
            ParraCredential.self,
            from: "{\"token\":\"something\"}".data(using: .utf8)!
        )
    }

    func testDecodesFromAccessToken() throws {
        let _ = try JSONDecoder.parraDecoder.decode(
            ParraCredential.self,
            from: "{\"access_token\":\"something\"}".data(using: .utf8)!
        )
    }

    func testEncodesToToken() throws {
        let data = try JSONEncoder().encode(ParraCredential(token: "something"))
        let decoded = try JSONDecoder().decode(
            [String: String].self,
            from: data
        )

        XCTAssert(decoded["token"] != nil)
    }
}
