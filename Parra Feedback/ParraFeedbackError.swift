//
//  ParraFeedbackError.swift
//  Parra Feedback
//
//  Created by Michael MacCallum on 2/26/22.
//

import Foundation

public enum ParraFeedbackError: Error, Equatable {
    public static func == (lhs: ParraFeedbackError, rhs: ParraFeedbackError) -> Bool {
        switch (lhs, rhs) {
        case (.missingAuthentication, .missingAuthentication):
            return true
        case (.authenticationFailed(let e1), .authenticationFailed(let e2)):
            return e1.localizedDescription == e2.localizedDescription
        case (.networkError(let e1), .networkError(let e2)):
            return e1.localizedDescription == e2.localizedDescription
        case (.jsonError(let e1), .jsonError(let e2)):
            return e1.localizedDescription == e2.localizedDescription
        case (.dataLoadingError(let e1), .dataLoadingError(let e2)):
            return e1.localizedDescription == e2.localizedDescription
        default:
            return false
        }
    }
    
    case missingAuthentication
    case authenticationFailed(Error)
    case networkError(Error)
    case jsonError(Error)
    case dataLoadingError(Error)
    case unknown
}
