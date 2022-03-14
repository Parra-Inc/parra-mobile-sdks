//
//  ParraError.swift
//  Parra Core
//
//  Created by Michael MacCallum on 2/26/22.
//

import Foundation

public enum ParraError: Error, Equatable {
    public static func == (lhs: ParraError, rhs: ParraError) -> Bool {
        switch (lhs, rhs) {
        case (.missingAuthentication, .missingAuthentication):
            return true
        case (.authenticationFailed(let e1), .authenticationFailed(let e2)):
            return e1 == e2
        case (.networkError(let e1), .networkError(let e2)):
            return e1 == e2
        case (.jsonError(let e1), .jsonError(let e2)):
            return e1 == e2
        case (.dataLoadingError(let e1), .dataLoadingError(let e2)):
            return e1 == e2
        case (.messageError(let m1), .messageError(let m2)):
            return m1 == m2
        default:
            return false
        }
    }
    
    case missingAuthentication
    case authenticationFailed(String)
    case networkError(String)
    case jsonError(String)
    case dataLoadingError(String)
    case messageError(String)
    case unknown
}
