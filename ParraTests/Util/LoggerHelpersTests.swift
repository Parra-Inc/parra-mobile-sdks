//
//  LoggerHelpersTests.swift
//  ParraTests
//
//  Created by Mick MacCallum on 6/25/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import XCTest
@testable import Parra

fileprivate enum LoggerTestError: Error {
    case exception
    case uniquelyNamedErrorCase
}

final class LoggerHelpersTests: XCTestCase {
    // MARK: - extractMessage

    func testExtractErrorMessageReturnsCustomParraErrors() {
        let extraMessage = "something"
        let error = ParraError.authenticationFailed(extraMessage)

        let result = LoggerHelpers.extractMessage(from: error)

        XCTAssertEqual(result, error.errorDescription)
    }

    func testExtractErrorMessageFromNsErrors() {
        let domain = "testDomain"
        let localizedDescription = "error description wooo"
        let code = 420

        let error = NSError(
            domain: domain,
            code: code,
            userInfo: [
                NSLocalizedDescriptionKey: localizedDescription
            ]
        )

        let result = LoggerHelpers.extractMessage(from: error)

        XCTAssertTrue(result.contains(domain))
        XCTAssertTrue(result.contains(localizedDescription))
        XCTAssertTrue(result.contains(String(code)))
    }

    func testExtractErrorMessageFromErrorProtocolTypes() {
        let error = LoggerTestError.uniquelyNamedErrorCase
        let result = LoggerHelpers.extractMessage(from: error)

        XCTAssertTrue(result.contains("LoggerTestError.uniquelyNamedErrorCase"))
    }

    // MARK: splitFileId

    func testSplitExpectedFileId() {
        splitAndAssertEqual(
            fileId: "Parra/LoggerHelpers.swift",
            expectedModule: "Parra",
            expectedFileName: "LoggerHelpers",
            expectedExtension: "swift"
        )
    }

    func testSplitEmptyFileId() {
        splitAndAssertEqual(
            fileId: "",
            expectedModule: "Unknown",
            expectedFileName: "Unknown",
            expectedExtension: ""
        )
    }

    func testSplitMissingModuleFileId() {
        splitAndAssertEqual(
            fileId: "LoggerHelpers.swift",
            expectedModule: "Unknown",
            expectedFileName: "LoggerHelpers",
            expectedExtension: "swift"
        )
    }

    func testSplitExtraFilePathComponentsFileId() {
        splitAndAssertEqual(
            fileId: "Parra/Intermediate/Folders/LoggerHelpers.swift",
            expectedModule: "Parra",
            expectedFileName: "Intermediate/Folders/LoggerHelpers",
            expectedExtension: "swift"
        )
    }

    func testSplitMissingExtensionFileId() {
        splitAndAssertEqual(
            fileId: "Parra/LoggerHelpers",
            expectedModule: "Parra",
            expectedFileName: "LoggerHelpers",
            expectedExtension: ""
        )
    }

    func testSplitMultipleFileExtensionsFileId() {
        splitAndAssertEqual(
            fileId: "Parra/LoggerHelpers.swift.gz",
            expectedModule: "Parra",
            expectedFileName: "LoggerHelpers",
            expectedExtension: "swift.gz"
        )
    }

    // MARK: - createFormattedLocation

    func testFormatsLogLocation() {
        let slug = LoggerHelpers.createFormattedLocation(
            fileId: "Parra/LoggerHelpers.swift",
            function: "createFormattedLocation(fileID:function:line:)",
            line: 69
        )

        XCTAssertEqual(slug, "Parra/LoggerHelpers.createFormattedLocation#69")
    }

    func testFormatsLogLocationMissingFileExtension() {
        let slug = LoggerHelpers.createFormattedLocation(
            fileId: "Parra/LoggerHelpers",
            function: "createFormattedLocation(fileID:function:line:)",
            line: 69
        )

        XCTAssertEqual(slug, "Parra/LoggerHelpers.createFormattedLocation#69")
    }

    func testFormatsLogLocationForFunctionsWithoutParams() {
        let slug = LoggerHelpers.createFormattedLocation(
            fileId: "Parra/LoggerHelpers.swift",
            function: "createFormattedLocation",
            line: 69
        )

        XCTAssertEqual(slug, "Parra/LoggerHelpers.createFormattedLocation#69")
    }

    private func splitAndAssertEqual(
        fileId: String,
        expectedModule: String,
        expectedFileName: String,
        expectedExtension: String
    ) {
        let (module, fileName, ext) = LoggerHelpers.splitFileId(
            fileId: fileId
        )

        XCTAssertTrue(module == expectedModule)
        XCTAssertTrue(fileName == expectedFileName)
        XCTAssertTrue(ext == expectedExtension)
    }
}
