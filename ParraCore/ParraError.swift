//
//  ParraError.swift
//  Parra Core
//
//  Created by Michael MacCallum on 2/26/22.
//

import Foundation

public enum ParraError: Error {
    case missingAuthentication
    case authenticationFailed(String)
    case networkError(String)
    case jsonError(String)
    case dataLoadingError(String)
    case messageError(String)
    case unknown
}
