//
//  CompletedCard.swift
//  ParraCore
//
//  Created by Mick MacCallum on 3/13/22.
//

import Foundation

public struct CompletedCard: Codable {
    public let questionId: String
    public let data: QuestionAnswer
    
    public init(questionId: String, data: QuestionAnswer) {
        self.questionId = questionId
        self.data = data
    }
}
