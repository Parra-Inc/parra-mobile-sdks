//
//  ParraError.swift
//  Parra Core
//
//  Created by Michael MacCallum on 2/26/22.
//

import Foundation

public enum ParraError: LocalizedError {
    case custom(String, Error?)
    case notInitialized
    case missingAuthentication
    case authenticationFailed(String)
    case networkError(status: Int, message: String, request: URLRequest)
    case jsonError(String)
    case unknown

    public var errorDescription: String {
        switch self {
        case .custom(let message, let error):
            if let error {
                return "\(message) Error: \(error.localizedDescription)"
            }

            return message
        case .notInitialized:
            return "Parra has not been initialized. Call Parra.initialize() in applicationDidFinishLaunchingWithOptions"
        case .missingAuthentication:
            return "An authentication provider has not been set. Add Parra.initialize() to your applicationDidFinishLaunchingWithOptions method."
        case .authenticationFailed(let error):
            return "Invoking the authentication provider passed to Parra.initialize() failed with error: \(error)"
        case .networkError(let status, let error, let request):
            return "A network error occurred performing request: \(request)\nReceived status code: \(status) with error: \(error)"
        case .jsonError(let error):
            return "An error occurred decoding JSON. Error: \(error)"
        case .unknown:
            return "An unknown error occurred."
        }
    }
}
