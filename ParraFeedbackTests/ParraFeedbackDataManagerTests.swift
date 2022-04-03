//
//  ParraFeedbackDataManagerTests.swift
//  Parra Feedback Tests
//
//  Created by Michael MacCallum on 1/4/22.
//

import XCTest
@testable import ParraFeedback

class ParraFeedbackDataManagerTests: XCTestCase {
    var dataManager: ParraFeedbackDataManager!

    override func setUpWithError() throws {
        dataManager = ParraFeedbackDataManager()
    }

    override func tearDownWithError() throws {
        dataManager = nil
    }
}
