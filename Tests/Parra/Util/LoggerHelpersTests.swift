//
//  LoggerHelpersTests.swift
//  Tests
//
//  Created by Mick MacCallum on 6/25/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

@testable import Parra
import XCTest

private enum LoggerTestError: Error {
    case exception
    case uniquelyNamedErrorCase
}

final class LoggerHelpersTests: XCTestCase {
    // MARK: - Internal

    // MARK: - extractMessage

    func testExtractErrorMessageReturnsCustomParraErrors() {
        let extraMessage = "something"
        let error = ParraError.authenticationFailed(extraMessage)

        let result = LoggerHelpers.extractMessageAndExtra(from: error)

        XCTAssertEqual(result.message, error.errorDescription)
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

        let result = LoggerHelpers.extractMessageAndExtra(from: error)

        XCTAssertTrue(result.message.contains(localizedDescription))
        XCTAssertEqual(result.extra?["domain"] as? String, domain)
        XCTAssertEqual(result.extra?["code"] as? Int, code)
    }

    func testExtractErrorMessageFromErrorProtocolTypes() {
        let error = LoggerTestError.uniquelyNamedErrorCase
        let result = LoggerHelpers.extractMessageAndExtra(from: error)

        XCTAssertTrue(
            result.message
                .contains("LoggerTestError.uniquelyNamedErrorCase")
        )
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
            expectedExtension: nil
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
            expectedExtension: nil
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

    // MARK: - Private

    private func splitAndAssertEqual(
        fileId: String,
        expectedModule: String,
        expectedFileName: String,
        expectedExtension: String?
    ) {
        let (module, fileName, ext) = LoggerHelpers.splitFileId(
            fileId: fileId
        )

        XCTAssertTrue(
            module == expectedModule,
            "Expected module from: \(fileId) to be \(expectedModule)"
        )
        XCTAssertTrue(
            fileName == expectedFileName,
            "Expected fileName from: \(fileId) to be \(expectedFileName)"
        )
        XCTAssertTrue(
            ext == expectedExtension,
            "Expected extension from: \(fileId) to be \(String(describing: expectedExtension))"
        )
    }
}
