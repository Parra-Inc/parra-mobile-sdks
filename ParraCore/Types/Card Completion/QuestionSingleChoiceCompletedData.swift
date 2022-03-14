//
//  QuestionSingleChoiceCompletedData.swift
//  ParraCore
//
//  Created by Mick MacCallum on 3/13/22.
//

import Foundation

public struct QuestionSingleChoiceCompletedData: Codable {
    public let optionId: String
    
    public init(optionId: String) {
        self.optionId = optionId
    }
}
