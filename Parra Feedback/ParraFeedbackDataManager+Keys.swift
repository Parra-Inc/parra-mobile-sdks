//
//  ParraFeedbackDataManager+Keys.swift
//  Parra Feedback
//
//  Created by Michael MacCallum on 3/2/22.
//

import Foundation

private let applicationSupportDirectory = FileManager.default.urls(
    for: .applicationSupportDirectory,
       in: .userDomainMask
).first!

extension ParraFeedbackDataManager {
    // !!! Think really hard before changing any of these.
    enum Path {
        static let parraDirectory = applicationSupportDirectory.appendingPathComponent("parra", isDirectory: true)
        static let parraFeedbackDirectory = parraDirectory.appendingPathComponent("feedback", isDirectory: true)
    }
    
    enum Key {
        static let userCredentialsKey = "com.parrafeedback.usercredential"
        static let cardsKey = "com.parrafeedback.cards.data"
        static let answersKey = "com.parrafeedback.answers.data"
    }
}
