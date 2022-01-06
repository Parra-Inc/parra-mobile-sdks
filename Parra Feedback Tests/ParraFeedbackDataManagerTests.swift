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
    
    func testCardDataMapFromList() {
        let cardData = [kSampleRadioQuestionItem.data, kSampleCheckboxQuestionItem.data]
        
        let result = dataManager.cardDataMapFromList(cardDataList: cardData)
        
        XCTAssert(result.count == cardData.count)
        for (index, data) in cardData.enumerated() {
            let loadedData = result[cardData[index].id]
            XCTAssertNotNil(loadedData)
            XCTAssert(loadedData?.index == index)
            XCTAssert(loadedData?.element == data)
        }
    }
    
    func testCardDataListFromMap() {
        let dataMap = [
            kSampleRadioQuestionItem.data.id: (0, kSampleRadioQuestionItem.data),
            kSampleCheckboxQuestionItem.data.id: (1, kSampleCheckboxQuestionItem.data),
        ]
        
        let result = dataManager.cardDataListFromMap(cardDataMap: dataMap)
        
        XCTAssert(result.count == dataMap.count)

        for (index, data) in result.enumerated() {
            XCTAssertNotNil(dataMap[data.id])
            XCTAssert(dataMap[data.id]?.1 == data)
            XCTAssert(dataMap[data.id]?.0 == index)
        }
    }
}
