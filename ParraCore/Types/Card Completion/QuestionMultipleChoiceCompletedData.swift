//
//  QuestionMultipleChoiceCompletedData.swift
//  ParraCore
//
//  Created by Mick MacCallum on 3/13/22.
//

import Foundation

public struct QuestionMultipleChoiceCompletedData: Codable {
    public let optionIds: [String]
    
    public init(optionIds: [String]) {
        self.optionIds = optionIds
    }
}
