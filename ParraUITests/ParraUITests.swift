//
//  ParraUITests.swift
//  ParraUITests
//
//  Created by Mick MacCallum on 7/4/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import XCTest

final class ParraUITests: MockedParraTestCase {
    
    override func setUp() async throws {
        try await super.setUp()

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
    }

    func testExample() async throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launchArguments.append("UITests")
        app.launch()

        app.tables.containing(.other, identifier:"PARRA FEEDBACK").element.tap()

        app.tables/*@START_MENU_TOKEN@*/.staticTexts["In a UIView"]/*[[".cells.staticTexts[\"In a UIView\"]",".staticTexts[\"In a UIView\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()

        app.windows.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.tap()

        app.navigationBars["Demo.ParraCardsInView"].buttons["Parra"].tap()

    }

//    func testLaunchPerformance() throws {
//        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
//            // This measures how long it takes to launch your application.
//            measure(metrics: [XCTApplicationLaunchMetric()]) {
//                XCUIApplication().launch()
//            }
//        }
//    }
}
